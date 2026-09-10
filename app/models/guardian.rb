class Guardian < ApplicationRecord
  include Tenanted
  belongs_to :user, optional: true
  has_many :guardianships, dependent: :destroy
  has_many :students, through: :guardianships
  validates :name, presence: true
end
