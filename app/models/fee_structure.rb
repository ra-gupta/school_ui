class FeeStructure < ApplicationRecord
  include Tenanted
  FREQUENCIES = %w[monthly quarterly annual one_time].freeze

  belongs_to :academic_year
  belongs_to :grade
  belongs_to :fee_head

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :frequency, inclusion: { in: FREQUENCIES }
  validates :due_day, inclusion: { in: 1..28 }
end
