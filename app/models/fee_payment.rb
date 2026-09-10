class FeePayment < ApplicationRecord
  include Tenanted
  METHODS = %w[cash upi card cheque online].freeze

  belongs_to :fee_invoice
  belongs_to :received_by, class_name: "User", optional: true

  validates :amount, numericality: { greater_than: 0 }
  validates :method, inclusion: { in: METHODS }

  before_validation { self.paid_at ||= Time.current }
  after_commit :refresh_invoice

  private

  def refresh_invoice = fee_invoice.refresh_totals!
end
