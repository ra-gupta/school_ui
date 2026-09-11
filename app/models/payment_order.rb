class PaymentOrder < ApplicationRecord
  include Tenanted
  belongs_to :user

  validates :gateway_order_id, presence: true, uniqueness: true
  validates :amount_paise, numericality: { greater_than: 0, only_integer: true }
  validates :status, inclusion: { in: %w[created paid failed] }

  def invoices = FeeInvoice.unscoped.where(id: allocations.keys)
  def allocation_for(invoice) = allocations.fetch(invoice.id.to_s) / 100.0
  def amount = amount_paise / 100.0
  def paid? = status == "paid"
end
