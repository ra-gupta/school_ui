class FeeInvoice < ApplicationRecord
  include Tenanted
  belongs_to :academic_year
  belongs_to :student
  has_many :fee_invoice_items, dependent: :destroy
  has_many :fee_payments, dependent: :destroy
  accepts_nested_attributes_for :fee_invoice_items, allow_destroy: true

  validates :number, presence: true, uniqueness: { scope: :school_id }
  validates :issue_date, :due_date, presence: true

  scope :unpaid,  -> { where(status: %w[unpaid partial]) }
  scope :overdue, -> { unpaid.where(due_date: ...Date.current) }

  before_validation :assign_number, on: :create

  def balance = (total + fine - discount - paid)
  def overdue? = balance.positive? && due_date < Date.current

  # Single source of truth for money state: recompute, never increment.
  def refresh_totals!
    self.total = fee_invoice_items.sum(:amount)
    self.paid  = fee_payments.where(status: "success").sum(:amount)
    self.status = if paid <= 0 then "unpaid"
                  elsif balance <= 0 then "paid"
                  else "partial"
                  end
    save!
  end

  private

  def assign_number
    self.number ||= "INV-#{Date.current.strftime("%Y%m")}-#{SecureRandom.alphanumeric(6).upcase}"
  end
end
