class LiveClass < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :section, optional: true
  belongs_to :subject, optional: true
  belongs_to :staff, optional: true

  validates :title, :starts_at, presence: true

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }

  manage module_key: "live_classes", search: %w[title], order: { starts_at: :desc },
         columns: [ { name: :starts_at, type: :datetime }, :title, { name: :section, type: :belongs_to },
                   { name: :subject, type: :belongs_to }, { name: :staff, type: :belongs_to },
                   :platform, :status ],
         fields: [ { name: :title, required: true }, { name: :starts_at, type: :datetime, required: true },
                  { name: :duration_minutes, type: :number },
                  { name: :section, type: :belongs_to, options: -> { Section.includes(:grade).order("grades.level", :name) } },
                  { name: :subject, type: :belongs_to },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :platform, type: :select, options: %w[meet zoom teams jitsi] },
                  :join_url,
                  { name: :status, type: :select, options: %w[scheduled live ended cancelled] } ]

  def name = title
  def ends_at = starts_at + duration_minutes.minutes
end
