class InventoryItem < ApplicationRecord
  include Tenanted, Manageable
  has_many :stock_movements, dependent: :destroy

  validates :name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :low_stock, -> { where("quantity <= reorder_level") }

  manage module_key: "inventory", search: %w[name code category], order: { name: :asc },
         columns: [:name, :code, :category, :unit,
                   { name: :quantity, type: :number, align: :right },
                   { name: :reorder_level, type: :number, align: :right },
                   { name: :unit_cost, type: :money, align: :right }],
         fields: [{ name: :name, required: true }, :code, :category, :unit,
                  { name: :quantity, type: :number }, { name: :reorder_level, type: :number },
                  { name: :unit_cost, type: :money }, :store]

  def low? = quantity <= reorder_level
end
