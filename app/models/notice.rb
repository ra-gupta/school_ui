class Notice < ApplicationRecord
  include Tenanted
  AUDIENCES = %w[all staff parents students section].freeze

  belongs_to :section, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :title, presence: true
  validates :audience, inclusion: { in: AUDIENCES }

  after_commit :announce, on: [ :create, :update ]

  scope :live, -> {
    where.not(published_at: nil).where(published_at: ..Time.current)
         .where("expires_on IS NULL OR expires_on >= ?", Date.current)
         .order(published_at: :desc)
  }

  private

  # Fires when a notice becomes published, not on every later edit.
  def announce
    return unless published_at.present? && published_at <= Time.current
    return unless previously_new_record? || saved_change_to_published_at?

    Notifications::NoticeJob.perform_later(id)
  end
end
