class KbArticle < ApplicationRecord
  include Tenanted, Manageable
  validates :title, :body, presence: true
  scope :published, -> { where(published: true) }

  manage module_key: "knowledge_base", search: %w[title category body], order: { title: :asc },
         columns: [ :title, :category, :audience, { name: :views, type: :number, align: :right },
                   { name: :published, type: :boolean } ],
         fields: [ { name: :title, required: true }, :category,
                  { name: :audience, type: :select, options: Notice::AUDIENCES },
                  { name: :body, type: :text, required: true },
                  { name: :published, type: :boolean } ]

  def name = title
end
