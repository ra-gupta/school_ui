class BookIssue < ApplicationRecord
  include Tenanted, Manageable
  belongs_to :book
  belongs_to :student, optional: true
  belongs_to :staff, optional: true

  validates :issued_on, :due_on, presence: true
  validate { errors.add(:base, "Pick a student or a staff member") if student_id.blank? && staff_id.blank? }

  scope :outstanding, -> { where(returned_on: nil) }
  scope :overdue, -> { outstanding.where(due_on: ...Date.current) }

  # A copy leaves the shelf on issue and comes back on return.
  after_create  { book.decrement!(:available) }
  after_update  { book.increment!(:available) if saved_change_to_returned_on? && returned_on.present? }
  after_destroy { book.increment!(:available) if returned_on.nil? }

  manage module_key: "library", search: [], order: { issued_on: :desc },
         columns: [{ name: :book, type: :belongs_to }, { name: :student, type: :belongs_to },
                   { name: :staff, type: :belongs_to }, { name: :issued_on, type: :date },
                   { name: :due_on, type: :date }, { name: :returned_on, type: :date },
                   { name: :fine, type: :money, align: :right }],
         fields: [{ name: :book, type: :belongs_to, required: true },
                  { name: :student, type: :belongs_to, options: -> { Student.active.order(:first_name) } },
                  { name: :staff, type: :belongs_to, options: -> { Staff.active.order(:first_name) } },
                  { name: :issued_on, type: :date, required: true },
                  { name: :due_on, type: :date, required: true },
                  { name: :returned_on, type: :date }, { name: :fine, type: :money }]

  def overdue? = returned_on.nil? && due_on < Date.current
end
