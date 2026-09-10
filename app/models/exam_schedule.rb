class ExamSchedule < ApplicationRecord
  belongs_to :exam
  belongs_to :section
  belongs_to :subject
  has_many :exam_results, dependent: :destroy
  validates :max_marks, numericality: { greater_than: 0 }
end
