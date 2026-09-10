class HostelAllocation < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :hostel_room
  belongs_to :student

  validates :from_on, presence: true
  validate :room_has_space, on: :create

  manage module_key: "hostel", search: [], order: { from_on: :desc },
         columns: [ { name: :student, type: :belongs_to }, { name: :hostel_room, type: :belongs_to },
                   :bed_no, { name: :from_on, type: :date }, { name: :to_on, type: :date } ],
         fields: [ { name: :student, type: :belongs_to, required: true, options: -> { Student.active.order(:first_name) } },
                  { name: :hostel_room, type: :belongs_to, required: true },
                  :bed_no, { name: :from_on, type: :date, required: true }, { name: :to_on, type: :date } ]

  private

  def room_has_space
    errors.add(:hostel_room, "is full") if hostel_room&.full?
  end
end
