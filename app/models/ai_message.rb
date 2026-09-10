class AiMessage < ApplicationRecord
  include Tenanted
  belongs_to :ai_conversation

  validates :body, presence: true
  validates :role, inclusion: { in: %w[user assistant] }

  after_create_commit { ai_conversation.update_column(:last_message_at, created_at) }
end
