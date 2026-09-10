class Payslip < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :staff

  validates :period, presence: true, uniqueness: { scope: :staff_id }
  validates :basic, :allowances, :deductions, numericality: { greater_than_or_equal_to: 0 }

  # Net is derived — never entered, so it can't drift from its parts.
  before_save { self.net_pay = basic + allowances - deductions }

  scope :for_period, ->(p) { where(period: p) }

  manage module_key: "payroll", search: %w[period], order: { period: :desc },
         columns: [ { name: :staff, type: :belongs_to }, :period,
                   { name: :basic, type: :money, align: :right },
                   { name: :allowances, type: :money, align: :right },
                   { name: :deductions, type: :money, align: :right },
                   { name: :net_pay, type: :money, align: :right }, :status ],
         fields: [ { name: :staff, type: :belongs_to, required: true, options: -> { Staff.active.order(:first_name) } },
                  { name: :period, required: true }, { name: :basic, type: :money },
                  { name: :allowances, type: :money }, { name: :deductions, type: :money },
                  { name: :days_present, type: :number },
                  { name: :status, type: :select, options: %w[draft approved paid] },
                  { name: :paid_on, type: :date } ]

  def name = "#{staff.name} · #{period}"
end
