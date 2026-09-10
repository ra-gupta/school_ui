class PhoneLog < ApplicationRecord
  include Tenanted, Manageable
  validates :called_at, presence: true

  manage module_key: "front_office", search: %w[caller_name phone purpose], order: { called_at: :desc },
         columns: [ :caller_name, :phone, :direction, :purpose, { name: :called_at, type: :datetime } ],
         fields: [ :caller_name, { name: :phone, type: :tel },
                  { name: :direction, type: :select, options: %w[incoming outgoing] },
                  :purpose, { name: :called_at, type: :datetime, required: true },
                  { name: :notes, type: :text } ]

  def name = caller_name
end
