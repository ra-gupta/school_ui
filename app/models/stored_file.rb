class StoredFile < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :uploaded_by, class_name: "User", optional: true
  has_one_attached :file

  validates :title, presence: true
  validate  :file_present

  manage module_key: "storage", search: %w[title folder description], order: { created_at: :desc },
         columns: [ :title, :folder, :visibility, { name: :created_at, type: :datetime } ],
         fields: [ { name: :title, required: true }, :folder,
                  { name: :visibility, type: :select, options: %w[staff parents students public] },
                  { name: :file, type: :file }, { name: :description, type: :text } ]

  def name = title
  def size = file.attached? ? ActiveSupport::NumberHelper.number_to_human_size(file.byte_size) : nil

  private

  # A row in the storage centre with nothing attached is just a broken link.
  def file_present
    errors.add(:file, "must be attached") unless file.attached?
  end
end
