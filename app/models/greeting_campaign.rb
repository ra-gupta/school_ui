class GreetingCampaign < ApplicationRecord
  include Tenanted, Manageable
  validates :title, presence: true

  manage module_key: "engagement", search: %w[title message], order: { title: :asc },
         columns: [ :title, :occasion, :audience, { name: :automatic, type: :boolean } ],
         fields: [ { name: :title, required: true },
                  { name: :occasion, type: :select, options: %w[birthday anniversary festival achievement welcome] },
                  { name: :audience, type: :select, options: Notice::AUDIENCES },
                  { name: :message, type: :text }, :background_color,
                  { name: :automatic, type: :boolean } ]

  def name = title
end
