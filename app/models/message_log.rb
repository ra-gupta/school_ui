class MessageLog < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :message_template, optional: true
  belongs_to :sent_by, class_name: "User", optional: true
  belongs_to :user, optional: true   # the person this alert is for

  validates :body, presence: true
  validates :channel, inclusion: { in: MessageTemplate::CHANNELS }

  scope :sent, -> { where(status: "sent") }
  scope :for_event, ->(event) { where(event:) }

  manage module_key: "communications", search: %w[recipient subject body], order: { created_at: :desc },
         columns: [ { name: :created_at, type: :datetime }, :channel, :audience, :recipient,
                   :subject, { name: :recipient_count, type: :number, align: :right }, :status ],
         fields: [ { name: :message_template, type: :belongs_to },
                  { name: :channel, type: :select, options: MessageTemplate::CHANNELS },
                  { name: :audience, type: :select, options: Notice::AUDIENCES },
                  :recipient, :subject, { name: :body, type: :text, required: true },
                  { name: :status, type: :select, options: %w[queued sent failed] } ]

  def name = subject.presence || body.truncate(40)
end
