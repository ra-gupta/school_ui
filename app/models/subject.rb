class Subject < ApplicationRecord
  include Tenanted
  belongs_to :grade, optional: true
  has_many :subject_assignments, dependent: :destroy
  validates :name, presence: true
end
