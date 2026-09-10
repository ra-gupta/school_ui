require "application_system_test_case"

# Smoke test + screenshot generator: every screen listed here must render, and
# lands in tmp/screenshots/ — for eyeballing locally, deliberately not
# committed. Add a `shot` line when you add a screen.
#   bin/rails test:system
class ScreenshotsTest < ApplicationSystemTestCase
  OUT = Rails.root.join("tmp/screenshots")

  # Seed once and keep it: reruns are then fast, and each test still gets a
  # fresh browser session (which is what makes switching users reliable).
  self.use_transactional_tests = false

  def setup
    FileUtils.mkdir_p(OUT)
    load Rails.root.join("db/seeds.rb") unless School.exists?
    Current.school = School.find_by(code: "SPS")
    Current.academic_year = Current.school.current_academic_year
  end

  test "school screens render" do
    shot "login", "/session/new"
    sign_in "principal@springfield.test"
    shot "dashboard", "/"

    student  = Student.active.joins(:enrollments).first
    invoice  = FeeInvoice.unpaid.first
    exam     = Exam.first
    schedule = exam.exam_schedules.first
    homework = Homework.first || Homework.create!(section: Section.first, title: "Read chapter 4",
                                                  description: "Questions 1–8.", assigned_on: Date.current, due_on: 3.days.from_now)

    shot "students",       "/students"
    shot "student_show",   "/students/#{student.id}"
    shot "student_new",    "/students/new"
    shot "staff",          "/hr"
    shot "staff_show",     "/hr/#{Staff.active.first.id}"
    shot "attendance",     "/attendance"
    shot "fees",           "/fees"
    shot "fee_invoice",    "/fees/invoices/#{invoice.id}"
    shot "fee_structures", "/fees/structures"
    shot "fee_heads",      "/fees/heads"
    shot "exams",          "/exams"
    shot "exam_show",      "/exams/#{exam.id}"
    shot "marks_entry",    "/exams/#{exam.id}/papers/#{schedule.id}/marks"
    shot "timetable",      "/timetable"
    shot "homework",       "/homework"
    shot "homework_show",  "/homework/#{homework.id}"
    shot "notices",        "/notices"
    shot "notice_show",    "/notices/#{Notice.live.first.id}"
    shot "academics",      "/academics"

    # Every enabled module's landing page, straight from the registry — a new
    # module is smoke-tested and screenshotted without touching this file.
    bespoke = %w[students academics attendance exams fees hr homework timetable notices]
    SchoolModule.all.each do |m|
      next if bespoke.include?(m.key) || !Current.school.module_enabled?(m.key)
      shot "module_#{m.key}", m.path
    end
  end

  test "platform screens render" do
    sign_in "super@erp.test"
    shot "schools",     "/schools"
    shot "school_edit", "/schools/#{School.find_by(code: "SPS").id}/edit"
  end

  private

  def sign_in(email, password = "password")
    steady do
      visit "/session/new"
      # Wait for this page's own document before touching a field: Capybara can
      # otherwise resolve one on the outgoing page and lose the node handle
      # while the browser navigates.
      assert_selector "form input[name='login']"
      fill_in "login", with: email
      fill_in "password", with: password
      click_on "Sign in"
    end
    assert_text User.find_by(email_address: email).name
  end

  # Chrome sometimes drops a node handle mid-navigation and reports "Node with
  # given id does not belong to the document". It is a race inside the driver,
  # not a fault on the page, so the step is retried once from the top. Any other
  # error is left alone — this must not paper over a real breakage.
  def steady
    attempts = 0
    begin
      yield
    rescue Selenium::WebDriver::Error::UnknownError => e
      raise unless e.message.include?("does not belong to the document")
      raise if (attempts += 1) > 1
      retry
    end
  end

  def shot(name, path)
    steady { visit path }
    assert page.has_no_text?("permission to do that", wait: 0), "#{name} (#{path}) was denied"
    assert page.has_no_text?("something went wrong", wait: 0), "#{name} (#{path}) errored"
    page.save_screenshot(OUT.join("#{name}.png").to_s)
  end
end
