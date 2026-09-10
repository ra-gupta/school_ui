class TestQuestion < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :online_test

  validates :prompt, presence: true
  validates :kind, inclusion: { in: %w[mcq true_false short] }
  validate  :answer_is_one_of_the_options, if: -> { kind == "mcq" }

  after_save    { online_test.refresh_total_marks! }
  after_destroy { online_test.refresh_total_marks! }

  manage module_key: "online_exams", search: %w[prompt], order: { position: :asc },
         columns: [ { name: :online_test, type: :belongs_to }, :prompt, :kind,
                   { name: :marks, type: :number, align: :right },
                   { name: :position, type: :number, align: :right } ],
         fields: [ { name: :online_test, type: :belongs_to, required: true },
                  { name: :prompt, type: :text, required: true },
                  { name: :kind, type: :select, options: %w[mcq true_false short] },
                  { name: :answer }, { name: :marks, type: :money },
                  { name: :position, type: :number } ]

  def name = prompt.truncate(60)
  def correct?(given) = kind == "short" ? given.to_s.casecmp?(answer.to_s) : given.to_s == answer.to_s

  private

  # A multiple-choice question whose answer is not on the list can never be
  # marked right, so it is rejected at the point it is written.
  def answer_is_one_of_the_options
    return if answer.blank? || options.include?(answer)
    errors.add(:answer, "must be one of the options")
  end
end
