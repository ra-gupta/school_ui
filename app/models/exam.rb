class Exam < ApplicationRecord
  include Tenanted
  belongs_to :academic_year
  has_many :exam_schedules, dependent: :destroy
  has_many :exam_results, through: :exam_schedules
  validates :name, presence: true
  scope :published, -> { where(published: true) }
end
