class Notice < ApplicationRecord
  include Tenanted
  AUDIENCES = %w[all staff parents students section].freeze

  belongs_to :section, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :title, presence: true
  validates :audience, inclusion: { in: AUDIENCES }

  scope :live, -> {
    where.not(published_at: nil).where(published_at: ..Time.current)
         .where("expires_on IS NULL OR expires_on >= ?", Date.current)
         .order(published_at: :desc)
  }
end
