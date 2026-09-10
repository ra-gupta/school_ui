class StudyMaterial < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :grade, optional: true
  belongs_to :subject, optional: true
  belongs_to :staff, optional: true

  validates :title, presence: true
  scope :published, -> { where(published: true) }

  manage module_key: "study_center", search: %w[title description], order: { created_at: :desc },
         columns: [ :title, :kind, { name: :grade, type: :belongs_to }, { name: :subject, type: :belongs_to },
                   { name: :downloads, type: :number, align: :right }, { name: :published, type: :boolean } ],
         fields: [ { name: :title, required: true },
                  { name: :kind, type: :select, options: %w[notes video worksheet link] },
                  { name: :grade, type: :belongs_to, options: -> { Grade.ordered } },
                  { name: :subject, type: :belongs_to },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  :url, { name: :description, type: :text }, { name: :published, type: :boolean } ]

  def name = title
end
