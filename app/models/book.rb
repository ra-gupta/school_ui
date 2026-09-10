class Book < ApplicationRecord
  include Tenanted, Manageable
  has_many :book_issues, dependent: :restrict_with_error

  validates :title, presence: true
  validates :copies, :available, numericality: { greater_than_or_equal_to: 0 }

  manage module_key: "library", search: %w[title author isbn],
         order: { title: :asc },
         columns: [ :title, :author, :isbn, :category, :rack,
                   { name: :copies, align: :right, type: :number },
                   { name: :available, align: :right, type: :number } ],
         fields: [ { name: :title, required: true }, :author, :isbn, :publisher, :category, :rack,
                  { name: :copies, type: :number }, { name: :available, type: :number },
                  { name: :price, type: :money } ]

  def name = title
end
