# Parent–teacher chat. A thread belongs to a teacher and a family; everyone
# else — including other staff — is kept out.
class ConversationsController < ApplicationController
  before_action -> { authorize!("chat.read") }
  before_action :set_conversation, only: [ :show, :update ]

  def index
    @conversations = visible.includes(:student, :staff, :guardian).recent.limit(50)
    @conversation = @conversations.first
    @messages = @conversation&.chat_messages&.includes(:sender) || []
  end

  def show
    @conversations = visible.includes(:student, :staff, :guardian).recent.limit(50)
    @messages = @conversation.chat_messages.includes(:sender)
    @conversation.chat_messages.where(read_at: nil).where.not(sender_id: current_user.id).update_all(read_at: Time.current)
    render :index
  end

  def create
    student = Student.find(params.require(:student_id))
    staff   = current_user.staff || student.section&.class_teacher
    convo = Conversation.find_or_create_by!(student:, staff:, guardian: student.guardians.first) do
      it.subject = params[:subject].presence || "General"
    end
    redirect_to convo
  end

  # Posting a reply is an update to the thread, not a resource of its own.
  def update
    message = @conversation.chat_messages.new(body: params.require(:body), sender: current_user)
    redirect_to @conversation, alert: message.save ? nil : "Message can't be blank."
  end

  private

  def visible
    return Conversation.all if current_user.can?("chat.moderate")
    Conversation.where(staff_id: current_user.staff&.id)
                .or(Conversation.where(guardian_id: current_user.guardian&.id))
                .or(Conversation.where(student_id: current_user.student&.id))
  end

  def set_conversation = @conversation = visible.find(params[:id])
end
