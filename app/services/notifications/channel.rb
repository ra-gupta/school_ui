module Notifications
  # A channel turns a rendered message into a delivery attempt. Adding a vendor
  # means one class with a #deliver, not a change anywhere else.
  class Channel
    class NotConfigured < StandardError; end

    ALL = {
      "email" => "Notifications::EmailChannel",
      "sms" => "Notifications::SmsChannel",
      "whatsapp" => "Notifications::WhatsappChannel",
      "push" => "Notifications::PushChannel"
    }.freeze

    def self.for(name) = ALL.fetch(name.to_s) { raise ArgumentError, "unknown channel #{name}" }.constantize.new

    def self.available = ALL.keys

    # Humanising the key gives "Sms" and "Whatsapp", which look like typos.
    LABELS = { "email" => "Email", "sms" => "SMS", "whatsapp" => "WhatsApp", "push" => "Push" }.freeze

    # What a person must have before a channel can reach them at all.
    NEEDS = { "email" => :email_address, "sms" => :phone, "whatsapp" => :phone, "push" => :app }.freeze

    def self.label(name) = LABELS.fetch(name.to_s, name.to_s.humanize)
    def self.needs(name) = NEEDS[name.to_s]

    # Return truthy on success. Raise NotConfigured when the vendor is not set
    # up — the log records that distinctly from a genuine failure, so an
    # unconfigured school is never mistaken for a broken one.
    def deliver(_log) = raise(NotImplementedError)

    private

    def recipient_address(log) = log.recipient
  end
end
