class Department < ApplicationRecord
  include Tenanted
  has_many :staffs, dependent: :nullify
  validates :name, presence: true
end
