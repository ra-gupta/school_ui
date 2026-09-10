class Staff < ApplicationRecord
  include Tenanted
  belongs_to :user, optional: true
  belongs_to :department, optional: true
  has_many :sections, foreign_key: :class_teacher_id, dependent: :nullify, inverse_of: :class_teacher
  has_many :subject_assignments, dependent: :nullify
  has_many :attendances, as: :attendable, dependent: :destroy

  validates :employee_no, :first_name, presence: true
  validates :employee_no, uniqueness: { scope: :school_id }

  scope :active, -> { where(status: "active") }

  def name = [first_name, last_name].compact_blank.join(" ")
end
