module Notifications
  # Deliberately not wired to a vendor yet: the account has not been chosen.
  # The seam is here so picking one is a single class, and until then the log
  # says "unconfigured" rather than pretending the message went out.
  class PushChannel < Channel
    def deliver(_log)
      raise NotConfigured, "Firebase Cloud Messaging is not configured — set FCM_SERVER_KEY" if ENV["FCM_SERVER_KEY"].blank?

      # ponytail: vendor call goes here once the account exists. Post the
      # rendered body to the gateway and return truthy on a 2xx.
      raise NotConfigured, "Firebase Cloud Messaging adapter not implemented"
    end
  end
end
