class Camera < ApplicationRecord
  include Tenanted, Manageable
  validates :name, presence: true

  manage module_key: "cctv", search: %w[name location], order: { name: :asc },
         columns: [ :name, :location, :stream_url, { name: :active, type: :boolean } ],
         fields: [ { name: :name, required: true }, :location, :stream_url,
                  { name: :active, type: :boolean } ]
end
