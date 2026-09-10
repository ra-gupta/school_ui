class AiAssistantController < ApplicationController
  before_action -> { authorize!("ai_assistant.read") }

  def show
    @conversations = AiConversation.where(user: current_user).recent.limit(20)
    @conversation = params[:id] ? @conversations.find(params[:id]) : @conversations.first
    @messages = @conversation&.ai_messages.to_a
    @configured = AiAssistant.configured?
  end

  def create
    question = params.require(:question).strip
    conversation = AiConversation.find_by(id: params[:id], user: current_user) ||
                   AiConversation.create!(user: current_user, title: question.truncate(60))

    conversation.ai_messages.create!(role: "user", body: question)

    # The assistant sees the exchange so far, minus the question just asked.
    history = conversation.ai_messages.where.not(id: conversation.ai_messages.last&.id)
                          .map { [ it.role, it.body ] }

    result = AiAssistant.new(current_user).ask(question, history:)
    conversation.ai_messages.create!(role: "assistant", body: result.text, model: result.model,
                                     input_tokens: result.input_tokens, output_tokens: result.output_tokens,
                                     cached_tokens: result.cached_tokens)
    redirect_to ai_assistant_path(id: conversation.id)
  rescue AiAssistant::NotConfigured
    redirect_to ai_assistant_path, alert: "Set ANTHROPIC_API_KEY on the server to use the assistant."
  rescue Anthropic::Errors::APIStatusError => e
    Rails.logger.error("AI assistant: #{e.class} #{e.message}")
    redirect_to ai_assistant_path(id: conversation&.id), alert: "The assistant is unavailable right now (#{e.type})."
  end
end
