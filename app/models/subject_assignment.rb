class SubjectAssignment < ApplicationRecord
  belongs_to :section
  belongs_to :subject
  belongs_to :staff, optional: true
end
