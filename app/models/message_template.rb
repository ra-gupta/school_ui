class MessageTemplate < ApplicationRecord
  include Tenanted, Manageable
  CHANNELS = %w[sms email whatsapp push].freeze

  has_many :message_logs, dependent: :nullify
  validates :name, :body, presence: true
  validates :channel, inclusion: { in: CHANNELS }

  manage module_key: "communications", search: %w[name subject body], order: { name: :asc },
         columns: [ :name, :channel, :subject, { name: :active, type: :boolean } ],
         fields: [ { name: :name, required: true },
                  { name: :channel, type: :select, options: CHANNELS },
                  :subject, { name: :body, type: :text, required: true },
                  { name: :active, type: :boolean } ]

  # {{name}} placeholders, filled when the message is queued.
  def render_with(values) = body.gsub(/\{\{(\w+)\}\}/) { values[Regexp.last_match(1)].to_s }
end
