class CampusWorker < ApplicationRecord
  include Tenanted, Manageable
  validates :name, presence: true

  manage module_key: "workers", search: %w[name role phone], order: { name: :asc },
         columns: [:name, :role, :phone, :shift,
                   { name: :daily_wage, type: :money, align: :right },
                   { name: :joined_on, type: :date }, :status],
         fields: [{ name: :name, required: true }, :role, { name: :phone, type: :tel },
                  { name: :shift, type: :select, options: ["morning", "afternoon", "night", "full day"] },
                  { name: :daily_wage, type: :money }, { name: :joined_on, type: :date },
                  { name: :status, type: :select, options: %w[active inactive] }]
end
