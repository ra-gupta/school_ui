class Competency < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :grade, optional: true
  belongs_to :subject, optional: true
  has_many :competency_scores, dependent: :destroy

  validates :name, presence: true

  manage module_key: "assessment", search: %w[name code domain], order: { name: :asc },
         columns: [ :code, :name, :domain, { name: :grade, type: :belongs_to },
                   { name: :subject, type: :belongs_to } ],
         fields: [ { name: :name, required: true }, :code, :domain,
                  { name: :grade, type: :belongs_to, options: -> { Grade.ordered } },
                  { name: :subject, type: :belongs_to }, { name: :description, type: :text } ]
end
