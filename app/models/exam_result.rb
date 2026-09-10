class ExamResult < ApplicationRecord
  belongs_to :exam_schedule
  belongs_to :student
  delegate :max_marks, :pass_marks, to: :exam_schedule

  validates :marks, numericality: { in: 0.. }, allow_nil: true
  validate  { errors.add(:marks, "exceeds maximum") if marks && marks > max_marks }

  before_save { self.grade = letter_grade }

  def percentage = marks && max_marks.positive? ? (marks / max_marks * 100).round(2) : nil
  def passed?    = !absent? && marks.to_d >= pass_marks

  def letter_grade
    return nil if absent? || marks.nil?
    case percentage
    when 90.. then "A+"
    when 80... then "A"
    when 70... then "B"
    when 60... then "C"
    when 50... then "D"
    when 33... then "E"
    else "F"
    end
  end
end
