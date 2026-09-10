class Enrollment < ApplicationRecord
  include Tenanted
  belongs_to :academic_year
  belongs_to :student
  belongs_to :section

  validates :student_id, uniqueness: { scope: :academic_year_id, message: "is already enrolled this year" }
  scope :active, -> { where(status: "active") }
end
