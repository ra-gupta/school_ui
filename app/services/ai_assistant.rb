# Answers a question using only the figures in SchoolContext.
#
# The brief is the whole point: an ERP assistant that answers from the model's
# own priors will confidently invent a fee total. The system prompt therefore
# tells it to say what it does not have rather than fill the gap.
class AiAssistant
  MODEL = "claude-opus-5"

  # Answers here are a few sentences over a small brief. This is a ceiling, not
  # a budget — only generated tokens are billed.
  MAX_TOKENS = 4096

  Result = Data.define(:text, :input_tokens, :output_tokens, :cached_tokens, :model)

  class NotConfigured < StandardError; end

  def self.configured? = ENV["ANTHROPIC_API_KEY"].present?

  def initialize(user, client: nil)
    @user = user
    @client = client
  end

  # history: [[role, body], ...] oldest first, excluding the new question.
  def ask(question, history: [])
    raise NotConfigured unless self.class.configured?

    messages = history.map { |role, body| { role:, content: body } } + [ { role: "user", content: question } ]

    response = client.messages.create(
      model: MODEL,
      max_tokens: MAX_TOKENS,
      # The brief is stable across the turns of a conversation, so it is the
      # cached prefix and the varying question comes after it.
      system_: [
        { type: "text", text: instructions },
        { type: "text", text: SchoolContext.new(@user).to_s, cache_control: { type: "ephemeral" } }
      ],
      messages:
    )

    Result.new(
      text: response.content.filter_map { it.text if it.type == :text }.join("\n").strip,
      input_tokens: response.usage&.input_tokens,
      output_tokens: response.usage&.output_tokens,
      cached_tokens: response.usage&.cache_read_input_tokens,
      model: MODEL
    )
  end

  private

  def client = @client ||= Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))

  def instructions
    <<~TEXT.strip
      You are the assistant inside a school management system. Answer using only
      the school brief that follows. It is the current state of this school's
      records.

      If the brief does not contain what was asked, say so plainly and name the
      screen where the person can find it — do not estimate, and do not answer
      from general knowledge about schools. Figures you were not given are
      figures you do not have.

      Be brief. Give the number first, then a sentence of context if it helps.
      Amounts are in the currency named in the brief.
    TEXT
  end
end
