class Survey < ApplicationRecord
  include Tenanted, Manageable
  has_many :survey_questions, -> { order(:position) }, dependent: :destroy, inverse_of: :survey
  has_many :survey_responses, through: :survey_questions

  validates :title, presence: true
  scope :live, -> { where(status: "open") }

  manage module_key: "surveys", search: %w[title description], order: { created_at: :desc },
         columns: [ :title, :audience, { name: :opens_on, type: :date }, { name: :closes_on, type: :date },
                   { name: :anonymous, type: :boolean }, :status ],
         fields: [ { name: :title, required: true }, { name: :description, type: :text },
                  { name: :audience, type: :select, options: Notice::AUDIENCES },
                  { name: :opens_on, type: :date }, { name: :closes_on, type: :date },
                  { name: :anonymous, type: :boolean },
                  { name: :status, type: :select, options: %w[draft open closed] } ]

  def name = title
  def response_count = survey_responses.count
end
