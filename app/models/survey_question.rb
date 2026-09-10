class SurveyQuestion < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :survey
  has_many :survey_responses, dependent: :destroy

  validates :prompt, presence: true
  validates :kind, inclusion: { in: %w[rating choice text] }

  manage module_key: "surveys", search: %w[prompt], order: { position: :asc },
         columns: [ { name: :survey, type: :belongs_to }, :prompt, :kind,
                   { name: :position, type: :number, align: :right } ],
         fields: [ { name: :survey, type: :belongs_to, required: true },
                  { name: :prompt, required: true },
                  { name: :kind, type: :select, options: %w[rating choice text] },
                  { name: :position, type: :number }, { name: :required, type: :boolean } ]

  def name = prompt

  # Rating questions are the only ones with a meaningful average.
  def average_rating = kind == "rating" ? survey_responses.average(:rating)&.round(2) : nil
end
