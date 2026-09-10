class WebPage < ApplicationRecord
  include Tenanted, Manageable
  validates :title, :slug, presence: true
  validates :slug, uniqueness: { scope: :school_id }, format: { with: /\A[a-z0-9-]+\z/, message: "letters, numbers and dashes only" }

  before_validation { self.slug = slug.presence || title.to_s.parameterize }
  scope :published, -> { where(published: true).order(:position) }

  manage module_key: "website", search: %w[title slug], order: { position: :asc },
         columns: [ :title, :slug, :section, { name: :position, type: :number, align: :right },
                   { name: :published, type: :boolean } ],
         fields: [ { name: :title, required: true }, :slug,
                  { name: :section, type: :select, options: %w[page news gallery] },
                  { name: :body, type: :text }, { name: :position, type: :number },
                  { name: :published, type: :boolean } ]

  def name = title
end
