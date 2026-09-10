class BackupRun < ApplicationRecord
  include Tenanted, Manageable
  validates :started_at, presence: true

  scope :succeeded, -> { where(status: "success") }

  manage module_key: "backups", search: %w[destination], order: { started_at: :desc },
         columns: [ { name: :started_at, type: :datetime }, :destination, :kind,
                   { name: :finished_at, type: :datetime }, :status ],
         fields: [ { name: :destination, type: :select, options: %w[local r2 b2 telegram] },
                  { name: :kind, type: :select, options: %w[full database files] },
                  { name: :started_at, type: :datetime, required: true },
                  { name: :finished_at, type: :datetime },
                  { name: :status, type: :select, options: %w[running success failed] } ]

  def name = "#{destination} · #{started_at.to_fs(:long)}"
  def duration = finished_at && (finished_at - started_at).round
  def size = size_bytes && ActiveSupport::NumberHelper.number_to_human_size(size_bytes)
end
