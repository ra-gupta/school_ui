class HomeworkSubmission < ApplicationRecord
  belongs_to :homework
  belongs_to :student
  scope :submitted, -> { where.not(submitted_at: nil) }
end
