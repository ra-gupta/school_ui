class Section < ApplicationRecord
  include Tenanted
  belongs_to :grade
  belongs_to :class_teacher, class_name: "Staff", optional: true
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
  has_many :subject_assignments, dependent: :destroy
  has_many :subjects, through: :subject_assignments
  has_many :timetable_slots, dependent: :destroy
  has_many :homeworks, dependent: :destroy

  validates :name, presence: true

  def full_name = "#{grade.name} #{name}"
  def full?     = enrollments.active.count >= capacity
end
