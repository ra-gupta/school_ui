class LessonPlan < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :section, optional: true
  belongs_to :subject, optional: true
  belongs_to :staff, optional: true

  validates :topic, :week_of, presence: true

  manage module_key: "lesson_plans", search: %w[topic objectives], order: { week_of: :desc },
         columns: [ { name: :week_of, type: :date }, { name: :section, type: :belongs_to },
                   { name: :subject, type: :belongs_to }, { name: :staff, type: :belongs_to },
                   :topic, :status ],
         fields: [ { name: :week_of, type: :date, required: true }, { name: :topic, required: true },
                  { name: :section, type: :belongs_to, options: -> { Section.includes(:grade).order("grades.level", :name) } },
                  { name: :subject, type: :belongs_to },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :objectives, type: :text }, { name: :activities, type: :text },
                  { name: :resources, type: :text },
                  { name: :status, type: :select, options: %w[planned delivered skipped] } ]

  def name = topic
end
