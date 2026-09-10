class LedgerEntry < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :recorded_by, class_name: "User", optional: true

  validates :description, :on_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :direction, inclusion: { in: %w[income expense] }

  scope :income,  -> { where(direction: "income") }
  scope :expense, -> { where(direction: "expense") }

  manage module_key: "accounts", search: %w[description category reference], order: { on_date: :desc },
         columns: [ { name: :on_date, type: :date }, :direction, :category, :description,
                   :payment_mode, { name: :amount, type: :money, align: :right } ],
         fields: [ { name: :direction, type: :select, options: %w[income expense] },
                  { name: :description, required: true }, :category,
                  { name: :amount, type: :money, required: true },
                  { name: :on_date, type: :date, required: true },
                  { name: :payment_mode, type: :select, options: %w[cash upi card cheque bank] },
                  :reference ]

  def name = description
end
