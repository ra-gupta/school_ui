class PtmMeeting < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :section, optional: true
  has_many :ptm_slots, dependent: :destroy

  validates :title, :on_date, presence: true

  manage module_key: "ptm", search: %w[title venue], order: { on_date: :desc },
         columns: [ :title, { name: :section, type: :belongs_to }, { name: :on_date, type: :date },
                   { name: :starts_at, type: :time }, { name: :ends_at, type: :time }, :venue, :status ],
         fields: [ { name: :title, required: true },
                  { name: :section, type: :belongs_to, options: -> { Section.includes(:grade).order("grades.level", :name) } },
                  { name: :on_date, type: :date, required: true },
                  { name: :starts_at, type: :time }, { name: :ends_at, type: :time },
                  { name: :slot_minutes, type: :number }, :venue,
                  { name: :status, type: :select, options: %w[scheduled open closed done] } ]

  def name = title

  # Cut the window into bookable slots for one teacher.
  def generate_slots!(staff)
    return if starts_at.blank? || ends_at.blank?
    at = starts_at
    while at < ends_at
      ptm_slots.find_or_create_by!(staff:, starts_at: at)
      at += slot_minutes.minutes
    end
  end
end
