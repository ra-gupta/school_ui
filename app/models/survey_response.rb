class SurveyResponse < ApplicationRecord
  include Tenanted
  belongs_to :survey_question
  belongs_to :user, optional: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
end
