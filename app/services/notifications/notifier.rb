module Notifications
  # Turns "this happened, tell these people" into queued delivery attempts.
  #
  # Wording comes from the school's own template for the event and channel when
  # it has one, and from the event's default otherwise — so a fresh install
  # notifies correctly before anyone opens the Communications module.
  class Notifier
    # dedupe_key: pass one to say "this person, about this thing, once". The
    # uniqueness is enforced by a partial index, so two workers racing on the
    # same event cannot both send.
    def self.deliver(event:, to:, values: {}, school: Current.school, dedupe_key: nil)
      new(event:, school:).deliver(Array(to), values, dedupe_key)
    end

    def initialize(event:, school:)
      @event = SchoolEvent[event] or raise ArgumentError, "unknown event #{event}"
      @school = school
    end

    def deliver(recipients, values, dedupe_key = nil)
      recipients.compact.uniq.sum { |user| queue_for(user, values, dedupe_key) }
    end

    private

    attr_reader :event, :school

    def queue_for(user, values, dedupe_key)
      return 0 unless user.active?
      return 0 if user.muted_events.include?(event.key)

      channels(user).sum do |channel|
        address = address_for(user, channel)
        next 0 if address.blank?

        log = MessageLog.create!(school:, user:, event: event.key, channel:, audience: event.audience,
                                 recipient: address, subject: event.name, body: render(channel, values),
                                 status: "queued", dedupe_key:)
        DeliveryJob.perform_later(log.id)
        1
      rescue ActiveRecord::RecordNotUnique
        0 # already told, by us or by another worker
      end
    end

    def channels(user) = user.notification_channels & Channel.available

    # Push goes to a device the app registered; there is no token store yet, so
    # it resolves to nothing and is skipped rather than queued to fail.
    def address_for(user, channel)
      case channel
      when "email" then user.email_address
      when "sms", "whatsapp" then user.phone
      end
    end

    def render(channel, values)
      body = template(channel)&.body || event.default_body
      body.gsub(/\{\{(\w+)\}\}/) { values[Regexp.last_match(1).to_sym].to_s }
    end

    def template(channel)
      @templates ||= MessageTemplate.where(school:, event: event.key, active: true).index_by(&:channel)
      @templates[channel]
    end
  end
end
