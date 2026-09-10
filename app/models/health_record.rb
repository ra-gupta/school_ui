class HealthRecord < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :student

  validates :checked_on, presence: true

  manage module_key: "health", search: [], order: { checked_on: :desc },
         columns: [ { name: :student, type: :belongs_to }, { name: :checked_on, type: :date },
                   { name: :height_cm, align: :right }, { name: :weight_kg, align: :right },
                   :blood_pressure, { name: :pulse, type: :number, align: :right }, :vision ],
         fields: [ { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :checked_on, type: :date, required: true },
                  { name: :height_cm, type: :money }, { name: :weight_kg, type: :money },
                  :blood_pressure, { name: :pulse, type: :number }, :vision,
                  { name: :allergies, type: :text }, { name: :notes, type: :text } ]

  def bmi = height_cm.to_f.positive? ? (weight_kg / (height_cm / 100)**2).round(1) : nil
end
