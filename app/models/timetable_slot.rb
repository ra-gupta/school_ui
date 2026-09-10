class TimetableSlot < ApplicationRecord
  include Tenanted
  belongs_to :academic_year
  belongs_to :section
  belongs_to :subject, optional: true
  belongs_to :staff, optional: true

  validates :weekday, inclusion: { in: 0..6 }
  validates :starts_at, :ends_at, presence: true
  validate  { errors.add(:ends_at, "must be after start") if starts_at && ends_at && ends_at <= starts_at }
  validate  :teacher_free

  scope :for_day, ->(wd) { where(weekday: wd).order(:starts_at) }

  private

  # A teacher can't be in two rooms at once.
  def teacher_free
    return if staff_id.blank? || starts_at.blank? || ends_at.blank?
    clash = TimetableSlot.where(academic_year_id:, staff_id:, weekday:)
                         .where.not(id: id)
                         .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
    errors.add(:staff, "already teaching another class at this time") if clash.exists?
  end
end
