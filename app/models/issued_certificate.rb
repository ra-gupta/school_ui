class IssuedCertificate < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :certificate_template
  belongs_to :student
  belongs_to :issued_by, class_name: "User", optional: true

  validates :issued_on, presence: true
  validates :number, presence: true, uniqueness: { scope: :school_id }

  before_validation on: :create do
    self.number ||= "CRT-#{Date.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
  end

  manage module_key: "certificates", search: %w[number], order: { issued_on: :desc },
         columns: [ :number, { name: :student, type: :belongs_to },
                   { name: :certificate_template, type: :belongs_to }, { name: :issued_on, type: :date } ],
         fields: [ { name: :certificate_template, type: :belongs_to, required: true },
                  { name: :student, type: :belongs_to, required: true, options: -> { Student.order(:first_name) } },
                  { name: :issued_on, type: :date, required: true }, { name: :remarks, type: :text } ]

  def name = number
  def body = certificate_template.render_for(student)
end
