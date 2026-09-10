module Notifications
  # Fired after a roster is marked. Attendance is written with upsert_all, which
  # cannot report which rows changed, so this reads the marked state and leans
  # on the dedupe key — re-saving a roster must not re-send.
  class AbsenceJob < ApplicationJob
    queue_as :default

    def perform(section_id, on_date)
      section = Section.unscoped.find_by(id: section_id) or return
      Current.school = section.school
      on_date = on_date.to_date

      absent = Attendance.unscoped.where(section_id:, on_date:, status: "absent", attendable_type: "Student")
      Student.unscoped.where(id: absent.select(:attendable_id)).includes(guardians: :user).find_each do |student|
        Notifier.deliver(event: "attendance_absent", to: student.contact_users, school: section.school,
                         dedupe_key: "absent:#{student.id}:#{on_date}",
                         values: { student: student.name, date: on_date.to_fs(:long), section: section.full_name })
      end
    ensure
      Current.school = nil
    end
  end
end
