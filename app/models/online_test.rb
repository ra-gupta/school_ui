class OnlineTest < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :academic_year, optional: true
  belongs_to :subject, optional: true
  belongs_to :grade, optional: true
  belongs_to :staff, optional: true
  has_many :test_questions, -> { order(:position) }, dependent: :destroy, inverse_of: :online_test
  has_many :test_attempts, dependent: :destroy

  validates :name, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }

  scope :open_now, -> { where(status: "published").where(opens_at: ..Time.current).where(closes_at: Time.current..) }

  # Total marks follow the paper, so adding a question cannot leave them stale.
  def refresh_total_marks! = update_column(:total_marks, test_questions.sum(:marks))

  manage module_key: "online_exams", search: %w[name], order: { opens_at: :desc },
         columns: [ :name, { name: :subject, type: :belongs_to }, { name: :grade, type: :belongs_to },
                   { name: :opens_at, type: :datetime }, { name: :duration_minutes, type: :number, align: :right },
                   { name: :total_marks, type: :number, align: :right }, :status ],
         fields: [ { name: :name, required: true },
                  { name: :subject, type: :belongs_to }, { name: :grade, type: :belongs_to, options: -> { Grade.ordered } },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :duration_minutes, type: :number },
                  { name: :opens_at, type: :datetime }, { name: :closes_at, type: :datetime },
                  { name: :pass_marks, type: :money }, { name: :shuffle_questions, type: :boolean },
                  { name: :status, type: :select, options: %w[draft published closed] },
                  { name: :instructions, type: :text } ]
end
