class Asset < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :assigned_to, class_name: "Staff", optional: true

  validates :name, presence: true

  manage module_key: "assets", search: %w[name code category], order: { name: :asc },
         columns: [:name, :code, :category, :location, { name: :assigned_to, type: :belongs_to },
                   { name: :cost, type: :money, align: :right }, :condition, :status],
         fields: [{ name: :name, required: true }, :code, :category,
                  { name: :purchased_on, type: :date }, { name: :cost, type: :money }, :location,
                  { name: :assigned_to, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :condition, type: :select, options: %w[good fair poor] },
                  { name: :status, type: :select, options: %w[in_use in_store repair disposed] },
                  { name: :warranty_expires_on, type: :date }]
end
