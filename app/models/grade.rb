class Grade < ApplicationRecord
  include Tenanted
  has_many :sections, dependent: :destroy
  has_many :subjects, dependent: :nullify
  has_many :fee_structures, dependent: :destroy
  validates :name, presence: true
  scope :ordered, -> { order(:level, :name) }
end
