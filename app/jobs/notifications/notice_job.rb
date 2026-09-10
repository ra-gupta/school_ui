module Notifications
  class NoticeJob < ApplicationJob
    queue_as :default

    def perform(notice_id)
      notice = Notice.unscoped.find_by(id: notice_id) or return
      Current.school = notice.school

      Notifier.deliver(event: "notice_published", to: recipients(notice), school: notice.school,
                       dedupe_key: "notice:#{notice.id}",
                       values: { title: notice.title, body: notice.body.to_s.truncate(300) })
    ensure
      Current.school = nil
    end

    private

    def recipients(notice)
      case notice.audience
      when "staff"    then User.active.where(school: notice.school, kind: %w[admin staff teacher])
      when "parents"  then User.active.where(school: notice.school, kind: "parent")
      when "students" then User.active.where(school: notice.school, kind: "student")
      when "section"  then notice.section&.students.to_a.flat_map(&:contact_users)
      else User.active.where(school: notice.school).where.not(kind: "super_admin")
      end.to_a
    end
  end
end
