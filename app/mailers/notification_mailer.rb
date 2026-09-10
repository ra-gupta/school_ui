class NotificationMailer < ApplicationMailer
  def notify(log)
    @log = log
    @school = log.school
    mail to: log.recipient, subject: "[#{@school.name}] #{log.subject}"
  end
end
