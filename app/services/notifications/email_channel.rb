module Notifications
  # Works out of the box — no vendor account needed, which is why it is the
  # default channel for a new account.
  class EmailChannel < Channel
    def deliver(log)
      raise NotConfigured, "no email address" if log.recipient.blank?
      NotificationMailer.notify(log).deliver_now
      true
    end
  end
end
