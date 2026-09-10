class FeeHead < ApplicationRecord
  include Tenanted
  has_many :fee_structures, dependent: :destroy
  validates :name, presence: true
end
