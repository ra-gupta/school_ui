class Visitor < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :meeting, class_name: "Staff", optional: true

  validates :name, :in_at, presence: true
  scope :inside, -> { where(out_at: nil) }

  manage module_key: "front_office", search: %w[name phone purpose], order: { in_at: :desc },
         columns: [:name, :phone, :purpose, { name: :meeting, type: :belongs_to },
                   :pass_no, { name: :in_at, type: :datetime }, { name: :out_at, type: :datetime }],
         fields: [{ name: :name, required: true }, { name: :phone, type: :tel }, :purpose,
                  { name: :meeting, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  :pass_no, { name: :party_size, type: :number },
                  { name: :in_at, type: :datetime, required: true }, { name: :out_at, type: :datetime }]
end
