class School < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :academic_years, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :staffs, dependent: :destroy
  has_many :grades, dependent: :destroy

  normalizes :subdomain, with: ->(s) { s.to_s.downcase.strip }

  validates :name, :code, :subdomain, presence: true
  validates :code, :subdomain, uniqueness: true
  validates :subdomain, format: { with: /\A[a-z0-9-]+\z/, message: "letters, numbers and dashes only" }

  scope :active, -> { where(active: true) }

  def current_academic_year = academic_years.find_by(current: true) || academic_years.order(:starts_on).last

  def module_enabled?(key)
    SchoolModule[key]&.core? || enabled_modules.include?(key.to_s)
  end

  def expired? = subscription_ends_on.present? && subscription_ends_on < Date.current
end
