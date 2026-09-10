class CertificateTemplate < ApplicationRecord
  include Tenanted, Manageable
  has_many :issued_certificates, dependent: :restrict_with_error

  validates :name, presence: true

  manage module_key: "certificates", search: %w[name], order: { name: :asc },
         columns: [ :name, :kind ],
         fields: [ { name: :name, required: true },
                  { name: :kind, type: :select, options: %w[bonafide transfer character conduct completion] },
                  { name: :body, type: :text } ]

  # {{student_name}} style placeholders, filled at issue time.
  def render_for(student)
    body.to_s.gsub(/\{\{(\w+)\}\}/) do
      { "student_name" => student.name, "admission_no" => student.admission_no,
        "class" => student.section&.full_name.to_s, "school" => student.school.name,
        "date" => Date.current.to_fs(:long) }.fetch(Regexp.last_match(1), "")
    end
  end
end
