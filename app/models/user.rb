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
  # Stored canonically so a number typed as "99000 00000" matches one stored as
  # "+919900000000" on an exact index lookup, rather than needing a LIKE scan.
  normalizes :phone, with: ->(p) { normalize_phone(p) }

  validates :email_address, :name, presence: true
  validates :email_address, uniqueness: true   # one login per person, platform-wide
  validates :phone, uniqueness: true, allow_nil: true
  validates :kind, inclusion: { in: KINDS }

  scope :active, -> { where(active: true) }

  class << self
    # Parents and students sign in with a mobile number; staff typically use an
    # email address. One field accepts either.
    def authenticate_by_login(login, password)
      login = login.to_s.strip
      return nil if login.blank? || password.blank?

      # authenticate_by rather than find_by + authenticate: it costs the same
      # bcrypt work whether or not the account exists, so the response time does
      # not reveal which mobile numbers are registered.
      if login.include?("@")
        active.authenticate_by(email_address: login, password:)
      else
        active.authenticate_by(phone: normalize_phone(login), password:)
      end
    end

    # Digits only, then the country code applied once. A local 10-digit number
    # and the same number written +91 / 0091 / 0-prefixed all land on one value.
    def normalize_phone(raw)
      digits = raw.to_s.gsub(/\D/, "")
      return nil if digits.blank?

      code = AppConfig[:default_country_code].to_s.delete("^0-9")
      digits = digits.delete_prefix("00")
      digits = digits.sub(/\A#{code}/, "") if code.present? && digits.length > 10
      digits = digits.sub(/\A0+/, "")
      "+#{code}#{digits}"
    end
  end

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

  def muted?(event) = muted_events.include?(event.to_s)

  # A channel is only usable if we hold the address it needs.
  def reachable_channels
    notification_channels.select { it == "email" ? email_address.present? : phone.present? }
  end
end
