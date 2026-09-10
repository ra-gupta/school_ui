class StockMovement < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :inventory_item
  belongs_to :recorded_by, class_name: "User", optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :direction, inclusion: { in: %w[in out] }
  validate  :enough_stock, on: :create

  # Stock level is derived from movements, so apply it here and nowhere else.
  after_create  { inventory_item.increment!(:quantity, signed_quantity) }
  after_destroy { inventory_item.decrement!(:quantity, signed_quantity) }

  manage module_key: "inventory", search: %w[reason], order: { on_date: :desc },
         columns: [{ name: :inventory_item, type: :belongs_to }, :direction,
                   { name: :quantity, type: :number, align: :right }, :reason,
                   { name: :on_date, type: :date }],
         fields: [{ name: :inventory_item, type: :belongs_to, required: true },
                  { name: :direction, type: :select, options: %w[in out] },
                  { name: :quantity, type: :number, required: true }, :reason,
                  { name: :on_date, type: :date, required: true }]

  private

  def signed_quantity = direction == "in" ? quantity : -quantity

  def enough_stock
    return unless direction == "out" && inventory_item
    errors.add(:quantity, "exceeds stock on hand (#{inventory_item.quantity})") if quantity > inventory_item.quantity
  end
end
