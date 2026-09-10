require "test_helper"

# The brief is the assistant's only source of truth, so what it may and may not
# contain is the part worth testing. No API call happens here.
class SchoolContextTest < ActiveSupport::TestCase
  setup do
    Current.school = @school = School.create!(name: "Test High", code: "THS", subdomain: "test-high")
    @other = School.create!(name: "Other High", code: "OHS", subdomain: "other-high")

    @admin = user_with(%w[*])
    Grade.create!(name: "Class 1", level: 1).then { |g| Section.create!(grade: g, name: "A") }
    Student.create!(admission_no: "THS001", first_name: "Asha", status: "active")

    Current.school = @other
    Student.create!(admission_no: "OHS001", first_name: "Ravi", status: "active")
    Current.school = @school
  end

  teardown { Current.school = nil }

  test "counts only the school in scope" do
    brief = SchoolContext.new(@admin).to_s

    assert_includes brief, "Test High"
    assert_includes brief, "Active students: 1"
    assert_not_includes brief, "Other High"
  end

  test "omits sections the asker may not read" do
    parent = user_with(%w[attendance.read])
    brief = SchoolContext.new(parent).to_s

    assert_includes brief, "## Attendance"
    assert_not_includes brief, "## Fees"
    assert_not_includes brief, "## Students"
  end

  test "includes fees only for someone who may read them" do
    assert_includes SchoolContext.new(@admin).to_s, "## Fees"
    assert_not_includes SchoolContext.new(user_with(%w[students.read])).to_s, "## Fees"
  end

  private

  def user_with(permissions)
    role = Role.create!(school: @school, name: "Role #{SecureRandom.hex(4)}", permissions:)
    user = User.create!(school: @school, name: "Asker", kind: "staff",
                        email_address: "asker-#{SecureRandom.hex(4)}@test.test", password: "password")
    user.roles = [ role ]
    user
  end
end
