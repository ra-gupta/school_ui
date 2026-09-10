class GatePass < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :student, optional: true
  belongs_to :staff, optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  validates :reason, :out_at, presence: true
  validate { errors.add(:base, "Pick a student or a staff member") if student_id.blank? && staff_id.blank? }

  scope :pending, -> { where(status: "pending") }

  manage module_key: "gate_pass", search: %w[reason], order: { out_at: :desc },
         columns: [{ name: :student, type: :belongs_to }, { name: :staff, type: :belongs_to },
                   :reason, { name: :out_at, type: :datetime }, { name: :in_at, type: :datetime }, :status],
         fields: [{ name: :student, type: :belongs_to, options: -> { Student.active.order(:first_name) } },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :reason, required: true }, { name: :out_at, type: :datetime, required: true },
                  { name: :in_at, type: :datetime },
                  { name: :status, type: :select, options: %w[pending approved rejected returned] }]

  def name = reason
end
