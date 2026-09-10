class AcademicYear < ApplicationRecord
  include Tenanted
  has_many :enrollments, dependent: :destroy
  has_many :exams, dependent: :destroy

  validates :name, :starts_on, :ends_on, presence: true
  validate  { errors.add(:ends_on, "must be after start") if starts_on && ends_on && ends_on <= starts_on }

  after_save { school.academic_years.where.not(id: id).update_all(current: false) if current? }
end
