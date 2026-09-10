class CompetencyScore < ApplicationRecord
  include Tenanted, Manageable
  LEVELS = %w[emerging developing proficient exemplary].freeze

  belongs_to :competency
  belongs_to :student
  belongs_to :assessed_by, class_name: "Staff", optional: true

  validates :term, presence: true
  validates :level, inclusion: { in: LEVELS }
  validates :student_id, uniqueness: { scope: [ :competency_id, :term ], message: "already has a level for this competency and term" }

  manage module_key: "assessment", search: %w[term], order: { assessed_on: :desc },
         columns: [ { name: :student, type: :belongs_to }, { name: :competency, type: :belongs_to },
                   :term, :level, { name: :assessed_on, type: :date } ],
         fields: [ { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :competency, type: :belongs_to, required: true },
                  { name: :term, type: :select, options: [ "Term 1", "Term 2", "Term 3" ] },
                  { name: :level, type: :select, options: LEVELS },
                  { name: :assessed_by, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :assessed_on, type: :date }, { name: :remarks, type: :text } ]

  def name = "#{student.name} · #{competency.name}"
end
