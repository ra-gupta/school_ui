class ChatMessage < ApplicationRecord
  include Tenanted
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  after_create_commit { conversation.update_column(:last_message_at, created_at) }
end
