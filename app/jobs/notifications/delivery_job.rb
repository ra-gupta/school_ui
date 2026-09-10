module Notifications
  class DeliveryJob < ApplicationJob
    queue_as :default
    retry_on StandardError, wait: :polynomially_longer, attempts: 3

    # A vendor that was never set up is not a failure worth retrying — record it
    # and stop, so an unconfigured school does not fill the queue with retries.
    discard_on Channel::NotConfigured

    def perform(message_log_id)
      log = MessageLog.unscoped.find_by(id: message_log_id) or return
      Current.school = log.school
      log.increment!(:attempts)

      Channel.for(log.channel).deliver(log)
      log.update!(status: "sent", delivered_at: Time.current, error: nil)
    rescue Channel::NotConfigured => e
      log&.update(status: "unconfigured", error: e.message)
      raise
    rescue StandardError => e
      log&.update(status: "failed", error: e.message.truncate(200))
      raise
    ensure
      Current.school = nil
    end
  end
end
