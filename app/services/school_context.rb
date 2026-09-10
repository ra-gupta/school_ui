# Builds the factual brief the assistant answers from.
#
# Two rules shape this. Everything is read through the tenant-scoped models, so
# one school's figures can never appear in another's answer. And each section is
# gated on the same permission as the screen it comes from, so the assistant
# cannot tell a parent something the UI would not show them — a model with a
# wider view than the user is a data leak with a chat box in front of it.
class SchoolContext
  def initialize(user) = @user = user

  def to_s = sections.compact.join("\n\n")

  private

  attr_reader :user

  def sections
    [ header, students, attendance, fees, academics, operations, notices ]
  end

  def may?(permission) = user.can?(permission)

  def header
    school = Current.school
    <<~TEXT.strip
      # #{school.name} (#{school.code})
      Academic year: #{Current.academic_year&.name || "not set"}
      Today: #{Date.current.to_fs(:long)}
      Currency: #{school.currency}
      Asking: #{user.display_name}, #{user.kind.humanize}
    TEXT
  end

  def students
    return unless may?("students.read")
    by_grade = Enrollment.active.joins(section: :grade).group(Arel.sql("grades.name")).count
    <<~TEXT.strip
      ## Students
      Active students: #{Student.active.count}
      Strength by class: #{by_grade.map { |g, n| "#{g}: #{n}" }.join(", ").presence || "none enrolled"}
      Staff on roll: #{Staff.active.count}
    TEXT
  end

  def attendance
    return unless may?("attendance.read")
    today = Attendance.where(attendable_type: "Student", on_date: Date.current).group(:status).count
    month = Attendance.where(attendable_type: "Student", on_date: Date.current.all_month)
    <<~TEXT.strip
      ## Attendance
      Today: #{today.map { |s, n| "#{s} #{n}" }.join(", ").presence || "not marked yet"}
      This month: #{month.present.count} present of #{month.count} marked
    TEXT
  end

  def fees
    return unless may?("fees.read")
    <<~TEXT.strip
      ## Fees
      Collected this month: #{Current.school.currency} #{FeePayment.where(paid_at: Date.current.all_month, status: "success").sum(:amount).to_i}
      Outstanding overall: #{Current.school.currency} #{FeeInvoice.unpaid.sum("total + fine - discount - paid").to_i}
      Invoices overdue: #{FeeInvoice.overdue.count}
    TEXT
  end

  def academics
    return unless may?("exams.read")
    exam = Exam.where(academic_year: Current.academic_year).order(starts_on: :desc).first
    return unless exam
    <<~TEXT.strip
      ## Latest exam
      #{exam.name} (#{exam.exam_type}), #{exam.starts_on&.to_fs(:long)} — #{exam.published? ? "results published" : "results not published"}
      Papers scheduled: #{exam.exam_schedules.count}
    TEXT
  end

  def operations
    return unless may?("library.read") || may?("transport.read")
    lines = []
    lines << "Books on issue: #{BookIssue.outstanding.count} (#{BookIssue.overdue.count} overdue)" if may?("library.read")
    lines << "Vehicles: #{Vehicle.count}, routes: #{TransportRoute.count}" if may?("transport.read")
    return if lines.empty?
    "## Operations\n#{lines.join("\n")}"
  end

  def notices
    return unless may?("notices.read")
    live = Notice.live.limit(3)
    return if live.empty?
    "## Current notices\n#{live.map { "- #{it.title}: #{it.body.to_s.truncate(120)}" }.join("\n")}"
  end
end
