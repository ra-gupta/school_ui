class Homework < ApplicationRecord
  include Tenanted
  belongs_to :section
  belongs_to :subject, optional: true
  belongs_to :staff, optional: true
  has_many :homework_submissions, dependent: :destroy
  validates :title, :assigned_on, presence: true
  scope :due, -> { where(due_on: Date.current..) }

  after_create_commit { Notifications::HomeworkJob.perform_later(id) }
end
