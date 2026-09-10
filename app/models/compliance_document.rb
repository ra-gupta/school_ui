class ComplianceDocument < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :owner, class_name: "Staff", optional: true

  validates :title, presence: true

  scope :expiring_within, ->(days) { where(expires_on: Date.current..days.days.from_now) }

  # Status is derived from the expiry date, so a certificate cannot sit in the
  # register marked valid a year after it lapsed.
  before_save do
    self.status = if expires_on.blank? then "valid"
    elsif expires_on < Date.current then "expired"
    elsif expires_on <= 30.days.from_now.to_date then "expiring"
    else "valid"
    end
  end

  manage module_key: "compliance", search: %w[title authority reference_no], order: { expires_on: :asc },
         columns: [ :title, :category, :authority, :reference_no,
                   { name: :issued_on, type: :date }, { name: :expires_on, type: :date }, :status ],
         fields: [ { name: :title, required: true }, :category, :authority, :reference_no,
                  { name: :owner, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :issued_on, type: :date }, { name: :expires_on, type: :date },
                  { name: :notes, type: :text } ]

  def name = title
end
