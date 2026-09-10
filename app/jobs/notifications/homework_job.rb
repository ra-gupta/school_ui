module Notifications
  class HomeworkJob < ApplicationJob
    queue_as :default

    def perform(homework_id)
      homework = Homework.unscoped.find_by(id: homework_id) or return
      Current.school = homework.school

      recipients = homework.section.students.includes(guardians: :user).flat_map(&:contact_users)
      Notifier.deliver(event: "homework_assigned", to: recipients, school: homework.school,
                       dedupe_key: "homework:#{homework.id}",
                       values: { title: homework.title, section: homework.section.full_name,
                                 subject: homework.subject&.name,
                                 due_on: homework.due_on&.to_fs(:long) || "no due date" })
    ensure
      Current.school = nil
    end
  end
end
