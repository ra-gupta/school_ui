class TestAttempt < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :online_test
  belongs_to :student

  validates :student_id, uniqueness: { scope: :online_test_id }

  manage module_key: "online_exams", search: [], order: { submitted_at: :desc },
         columns: [ { name: :online_test, type: :belongs_to }, { name: :student, type: :belongs_to },
                   { name: :started_at, type: :datetime }, { name: :submitted_at, type: :datetime },
                   { name: :score, type: :number, align: :right }, :status ],
         fields: [ { name: :online_test, type: :belongs_to, required: true },
                  { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :started_at, type: :datetime }, { name: :submitted_at, type: :datetime },
                  { name: :score, type: :money },
                  { name: :status, type: :select, options: %w[in_progress submitted graded] } ]

  def name = "#{student.name} · #{online_test.name}"

  # Marked from the stored answers rather than trusting a score sent by the
  # client, which is the whole point of keeping the answer sheet server-side.
  def grade!
    earned = online_test.test_questions.sum { it.correct?(answers[it.id.to_s]) ? it.marks : 0 }
    update!(score: earned, status: "graded", submitted_at: submitted_at || Time.current)
  end

  def passed? = score.present? && score >= online_test.pass_marks
end
