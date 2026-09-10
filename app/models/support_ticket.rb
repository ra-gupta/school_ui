class SupportTicket < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :raised_by, class_name: "User", optional: true
  belongs_to :assigned_to, class_name: "User", optional: true

  validates :subject, presence: true

  scope :open, -> { where.not(status: %w[resolved closed]) }

  before_save { self.resolved_at ||= Time.current if status == "resolved" }

  manage module_key: "support", search: %w[subject body category], order: { created_at: :desc },
         columns: [ { name: :created_at, type: :datetime }, :subject, :category, :priority,
                   { name: :assigned_to, type: :belongs_to }, :status ],
         fields: [ { name: :subject, required: true }, { name: :body, type: :text }, :category,
                  { name: :priority, type: :select, options: %w[low normal high urgent] },
                  { name: :assigned_to, type: :belongs_to, options: -> { User.active.where(kind: %w[admin staff]) } },
                  { name: :status, type: :select, options: %w[open in_progress waiting resolved closed] } ]

  def name = subject
end
