class PostalRecord < ApplicationRecord
  include Tenanted, Manageable
  validates :on_date, presence: true

  manage module_key: "front_office", search: %w[reference_no from_name to_name], order: { on_date: :desc },
         columns: [:direction, :reference_no, :from_name, :to_name, { name: :on_date, type: :date }],
         fields: [{ name: :direction, type: :select, options: %w[received dispatched] },
                  :reference_no, :from_name, :to_name,
                  { name: :on_date, type: :date, required: true }, { name: :notes, type: :text }]

  def name = reference_no
end
