class TransportAssignment < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :student
  belongs_to :transport_route
  belongs_to :route_stop, optional: true

  validates :student_id, uniqueness: { scope: :transport_route_id }

  manage module_key: "transport", search: [], order: { id: :desc },
         columns: [ { name: :student, type: :belongs_to }, { name: :transport_route, type: :belongs_to },
                   { name: :route_stop, type: :belongs_to }, :direction ],
         fields: [ { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :transport_route, type: :belongs_to, required: true },
                  { name: :route_stop, type: :belongs_to },
                  { name: :direction, type: :select, options: %w[both pickup drop] } ]
end
