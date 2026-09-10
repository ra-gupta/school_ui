class FeeInvoiceItem < ApplicationRecord
  belongs_to :fee_invoice
  belongs_to :fee_head, optional: true
  validates :description, presence: true
  validates :amount, numericality: true
end
