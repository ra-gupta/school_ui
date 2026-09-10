class AdmissionEnquiry < ApplicationRecord
  include Tenanted, Manageable
  STATUSES = %w[new contacted visited applied admitted lost].freeze

  belongs_to :grade, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true

  validates :student_name, :enquired_on, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :open, -> { where.not(status: %w[admitted lost]) }
  scope :due_today, -> { open.where(follow_up_on: ..Date.current) }

  manage module_key: "admissions", search: %w[student_name guardian_name phone email],
         order: { enquired_on: :desc },
         columns: [ :student_name, :guardian_name, :phone, { name: :grade, type: :belongs_to },
                   :source, :status, { name: :follow_up_on, type: :date } ],
         fields: [ { name: :student_name, required: true }, :guardian_name,
                  { name: :phone, type: :tel }, { name: :email, type: :email },
                  { name: :grade, type: :belongs_to, options: -> { Grade.ordered } },
                  { name: :source, type: :select, options: [ "Walk-in", "Website", "Referral", "Phone", "Social media" ] },
                  { name: :status, type: :select, options: STATUSES },
                  { name: :enquired_on, type: :date, required: true },
                  { name: :follow_up_on, type: :date },
                  { name: :assigned_to, type: :belongs_to, options: -> { User.active.where(kind: %w[admin staff]) } },
                  { name: :notes, type: :text } ]

  def name = student_name
end
