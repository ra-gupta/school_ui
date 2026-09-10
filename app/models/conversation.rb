class Conversation < ApplicationRecord
  include Tenanted
  belongs_to :student, optional: true
  belongs_to :staff
  belongs_to :guardian, optional: true
  has_many :chat_messages, -> { order(:created_at) }, dependent: :destroy, inverse_of: :conversation

  scope :recent, -> { order(Arel.sql("last_message_at DESC NULLS LAST")) }

  def title = [ student&.name, subject ].compact_blank.join(" · ").presence || "Conversation ##{id}"

  # Both sides of a thread: the teacher, and the guardian or the student.
  def participant_ids = [ staff&.user_id, guardian&.user_id, student&.user_id ].compact

  def unread_for(user) = chat_messages.where(read_at: nil).where.not(sender_id: user.id).count
end
