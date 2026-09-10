class HostelRoom < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :hostel
  has_many :hostel_allocations, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :hostel_id }

  manage module_key: "hostel", search: %w[number], order: { number: :asc },
         columns: [ { name: :hostel, type: :belongs_to }, :number, :kind,
                   { name: :capacity, type: :number, align: :right },
                   { name: :rent, type: :money, align: :right } ],
         fields: [ { name: :hostel, type: :belongs_to, required: true },
                  { name: :number, required: true },
                  { name: :kind, type: :select, options: %w[single shared dormitory] },
                  { name: :capacity, type: :number }, { name: :rent, type: :money } ]

  def name = "#{hostel.name} · #{number}"
  def occupied = hostel_allocations.where(to_on: nil).count
  def full? = occupied >= capacity
end
