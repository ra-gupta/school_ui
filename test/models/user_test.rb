require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  # The system suite seeds a whole school and deliberately leaves it behind, so
  # these tests stay off the numbers it hands out (+9197/98/99 ...) and use the
  # +9190 range instead.
  test "normalises every spelling of a mobile number to one value" do
    canonical = "+919000000000"
    [ "9000000000", "90000 00000", "+91 90000-00000", "0091 9000000000", "09000000000" ].each do |written|
      assert_equal canonical, User.normalize_phone(written), "#{written.inspect} should normalise"
    end
  end

  test "normalises a blank number to nil rather than a bare country code" do
    assert_nil User.normalize_phone("")
    assert_nil User.normalize_phone(nil)
    assert_nil User.normalize_phone("   ")
  end

  test "stores the normalised number on write" do
    user = User.new(phone: "90000 00001")
    assert_equal "+919000000001", user.phone
  end

  test "a mobile number identifies exactly one account" do
    User.create!(name: "First", email_address: "first@erp.test", phone: "9000000002",
                 kind: "staff", password: "password")
    duplicate = User.new(name: "Second", email_address: "second@erp.test", phone: "+91 90000 00002",
                         kind: "staff", password: "password")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:phone], "has already been taken"
  end
end
