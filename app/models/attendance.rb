class Attendance < ApplicationRecord
  include Tenanted
  STATUSES = %w[present absent late half_day leave holiday].freeze

  belongs_to :academic_year, optional: true
  belongs_to :attendable, polymorphic: true
  belongs_to :section, optional: true
  belongs_to :marked_by, class_name: "User", optional: true

  validates :on_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :attendable_id, uniqueness: { scope: [ :attendable_type, :on_date ] }

  scope :on, ->(date) { where(on_date: date) }
  scope :present, -> { where(status: %w[present late half_day]) }
end
