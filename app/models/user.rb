class User < ApplicationRecord
  KINDS = %w[super_admin admin staff teacher parent student driver].freeze

  belongs_to :school, optional: true          # super_admin has no school
  has_many :sessions, dependent: :destroy
  has_many :role_assignments, dependent: :destroy
  has_many :roles, through: :role_assignments
  has_one  :staff, dependent: :nullify
  has_one  :student, dependent: :nullify
  has_one  :guardian, dependent: :nullify

  has_secure_password
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, :name, presence: true
  validates :email_address, uniqueness: true   # one login per person, platform-wide
  validates :kind, inclusion: { in: KINDS }

  scope :active, -> { where(active: true) }

  def super_admin? = kind == "super_admin"

  def permissions
    @permissions ||= roles.flat_map(&:permissions).uniq
  end

  # "fees.collect" matches an exact grant, a "fees.*" module grant, or "*".
  def can?(permission)
    return true if super_admin? || permissions.include?("*")
    permissions.include?(permission.to_s) ||
      permissions.include?("#{permission.to_s.split(".").first}.*")
  end

  def display_name = name.presence || email_address
end
