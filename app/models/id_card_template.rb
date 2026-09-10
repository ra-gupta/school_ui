class IdCardTemplate < ApplicationRecord
  include Tenanted, Manageable
  validates :name, presence: true

  manage module_key: "id_cards", search: %w[name], order: { name: :asc },
         columns: [:name, :audience, :orientation, { name: :active, type: :boolean }],
         fields: [{ name: :name, required: true },
                  { name: :audience, type: :select, options: %w[student staff] },
                  { name: :orientation, type: :select, options: %w[portrait landscape] },
                  :background_color, { name: :active, type: :boolean }]
end
