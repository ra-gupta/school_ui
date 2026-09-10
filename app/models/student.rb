class Student < ApplicationRecord
  include Tenanted
  belongs_to :user, optional: true
  has_many :enrollments, dependent: :destroy
  has_many :sections, through: :enrollments
  has_many :guardianships, dependent: :destroy
  has_many :guardians, through: :guardianships
  has_many :attendances, as: :attendable, dependent: :destroy
  has_many :fee_invoices, dependent: :destroy
  has_many :exam_results, dependent: :destroy
  has_many :homework_submissions, dependent: :destroy

  validates :admission_no, :first_name, presence: true
  validates :admission_no, uniqueness: { scope: :school_id }

  scope :active, -> { where(status: "active") }
  scope :search, ->(q) {
    q.blank? ? all : where(
      "first_name ILIKE :q OR last_name ILIKE :q OR admission_no ILIKE :q OR phone ILIKE :q",
      q: "%#{q}%"
    )
  }

  def name = [first_name, last_name].compact_blank.join(" ")
  def current_enrollment = enrollments.find_by(academic_year: Current.academic_year) || enrollments.order(:id).last
  def section = current_enrollment&.section
  def fees_due = fee_invoices.unpaid.sum(&:balance)
end
