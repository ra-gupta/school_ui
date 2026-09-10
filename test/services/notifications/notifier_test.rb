require "test_helper"

class Notifications::NotifierTest < ActiveJob::TestCase
  setup do
    Current.school = @school = School.create!(name: "Notify High", code: "NTF", subdomain: "notify-high")
    @parent = User.create!(school: @school, name: "Parent", kind: "parent",
                           email_address: "parent@notify.test", phone: "+919000111222",
                           password: "password", notification_channels: %w[email sms])
  end

  teardown { Current.school = nil }

  def deliver(**overrides)
    Notifications::Notifier.deliver(**{ event: "attendance_absent", to: [ @parent ],
                                        values: { student: "Asha", date: "1 May" } }.merge(overrides))
  end

  test "queues one message per channel the person accepts" do
    assert_difference -> { MessageLog.count }, 2 do
      assert_equal 2, deliver
    end
    assert_equal %w[email sms], MessageLog.order(:channel).pluck(:channel)
    assert_enqueued_jobs 2, only: Notifications::DeliveryJob
  end

  test "skips a channel with no address for it" do
    @parent.update!(phone: nil)
    assert_difference -> { MessageLog.count }, 1 do
      deliver
    end
    assert_equal "email", MessageLog.sole.channel
  end

  test "sends nothing for an event the person muted" do
    @parent.update!(muted_events: %w[attendance_absent])
    assert_no_difference -> { MessageLog.count } do
      assert_equal 0, deliver
    end
  end

  test "sends nothing to a deactivated account" do
    @parent.update!(active: false)
    assert_no_difference(-> { MessageLog.count }) { deliver }
  end

  test "a dedupe key means once, however many times it is called" do
    assert_difference(-> { MessageLog.count }, 2) { deliver(dedupe_key: "absent:1:2026-05-01") }
    assert_no_difference(-> { MessageLog.count }) { deliver(dedupe_key: "absent:1:2026-05-01") }
  end

  test "without a dedupe key the same alert can be sent again" do
    assert_difference -> { MessageLog.count }, 4 do
      2.times { deliver }
    end
  end

  test "fills placeholders from the event's default wording" do
    deliver
    assert_includes MessageLog.first.body, "Asha was marked absent on 1 May"
    assert_not_includes MessageLog.first.body, "{{"
  end

  test "prefers the school's own template for that event and channel" do
    MessageTemplate.create!(school: @school, name: "Custom absence", channel: "sms",
                            event: "attendance_absent", body: "{{student}} missed school. — {{date}}")

    deliver
    assert_equal "Asha missed school. — 1 May", MessageLog.find_by(channel: "sms").body
    assert_includes MessageLog.find_by(channel: "email").body, "Please contact the class teacher"
  end
end
