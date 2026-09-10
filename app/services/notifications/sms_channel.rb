module Notifications
  # Deliberately not wired to a vendor yet: the account has not been chosen.
  # The seam is here so picking one is a single class, and until then the log
  # says "unconfigured" rather than pretending the message went out.
  class SmsChannel < Channel
    def deliver(_log)
      raise NotConfigured, "an SMS gateway is not configured — set SMS_API_KEY" if ENV["SMS_API_KEY"].blank?

      # ponytail: vendor call goes here once the account exists. Post the
      # rendered body to the gateway and return truthy on a 2xx.
      raise NotConfigured, "an SMS gateway adapter not implemented"
    end
  end
end
