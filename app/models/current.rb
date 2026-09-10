class Current < ActiveSupport::CurrentAttributes
  attribute :session, :school, :academic_year
  delegate :user, to: :session, allow_nil: true
end
