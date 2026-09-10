class AiConversation < ApplicationRecord
  include Tenanted
  belongs_to :user
  has_many :ai_messages, -> { order(:created_at) }, dependent: :destroy, inverse_of: :ai_conversation

  scope :recent, -> { order(Arel.sql("last_message_at DESC NULLS LAST")) }

  def display_title = title.presence || "New conversation"
end
