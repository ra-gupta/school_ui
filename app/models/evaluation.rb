class Evaluation < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :exam_schedule
  belongs_to :student
  belongs_to :evaluator, class_name: "Staff", optional: true

  validates :student_id, uniqueness: { scope: :exam_schedule_id }
  validate  :marks_within_paper

  manage module_key: "digital_eval", search: [], order: { evaluated_at: :desc },
         columns: [ { name: :student, type: :belongs_to }, { name: :exam_schedule, type: :belongs_to },
                   { name: :evaluator, type: :belongs_to },
                   { name: :marks, type: :number, align: :right }, :status,
                   { name: :evaluated_at, type: :datetime } ],
         fields: [ { name: :exam_schedule, type: :belongs_to, required: true },
                  { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :evaluator, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :marks, type: :money },
                  { name: :status, type: :select, options: %w[pending in_review completed] },
                  { name: :evaluated_at, type: :datetime }, { name: :remarks, type: :text } ]

  def name = "#{student.name} · #{exam_schedule.subject.name}"

  private

  def marks_within_paper
    return if marks.blank? || exam_schedule.blank?
    errors.add(:marks, "exceeds the paper's maximum") if marks > exam_schedule.max_marks
  end
end
