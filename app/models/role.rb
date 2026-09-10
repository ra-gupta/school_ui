class Role < ApplicationRecord
  belongs_to :school, optional: true          # nil = global template role
  has_many :role_assignments, dependent: :destroy
  has_many :users, through: :role_assignments

  validates :name, presence: true
end
