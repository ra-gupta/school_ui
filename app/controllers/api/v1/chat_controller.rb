module Api
  module V1
    class ChatController < BaseController
      before_action -> { authorize!("chat.read") }

      def index
        render json: visible.includes(:student, :staff).recent.limit(50).map { |c|
          { id: c.id, title: c.title, subject: c.subject, last_message_at: c.last_message_at,
            unread: c.unread_for(current_user), preview: c.chat_messages.last&.body }
        }
      end

      def show
        convo = visible.find(params[:id])
        convo.chat_messages.where(read_at: nil).where.not(sender_id: current_user.id).update_all(read_at: Time.current)
        render json: { id: convo.id, title: convo.title,
                       messages: convo.chat_messages.includes(:sender).map { |m|
                         { id: m.id, body: m.body, at: m.created_at, mine: m.sender_id == current_user.id,
                           sender: m.sender.display_name }
                       } }
      end

      def create
        convo = visible.find(params[:id])
        message = convo.chat_messages.new(body: params.require(:body), sender: current_user)
        return render(json: { error: "invalid" }, status: :unprocessable_entity) unless message.save
        render json: { id: message.id, body: message.body, at: message.created_at }, status: :created
      end

      private

      def visible
        return Conversation.all if current_user.can?("chat.moderate")
        Conversation.where(staff_id: current_user.staff&.id)
                    .or(Conversation.where(guardian_id: current_user.guardian&.id))
                    .or(Conversation.where(student_id: current_user.student&.id))
      end
    end
  end
end
