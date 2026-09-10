class PtmSlot < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :ptm_meeting
  belongs_to :staff, optional: true
  belongs_to :student, optional: true

  validates :starts_at, presence: true

  scope :open, -> { where(status: "open") }

  manage module_key: "ptm", search: [], order: { starts_at: :asc },
         columns: [ { name: :ptm_meeting, type: :belongs_to }, { name: :starts_at, type: :time },
                   { name: :staff, type: :belongs_to }, { name: :student, type: :belongs_to }, :status ],
         fields: [ { name: :ptm_meeting, type: :belongs_to, required: true },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :student, type: :belongs_to, options: -> { Student.active.order(:first_name) } },
                  { name: :starts_at, type: :time, required: true },
                  { name: :status, type: :select, options: %w[open booked attended missed] },
                  { name: :remarks, type: :text } ]

  def name = "#{starts_at.strftime("%H:%M")} · #{staff&.name}"
end
