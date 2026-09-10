module Notifications
  # Runs daily over every school. Reminds about invoices falling due shortly,
  # once per invoice per person — without that guard a daily job would nag every
  # morning until the fee is paid.
  class FeeReminderJob < ApplicationJob
    queue_as :default
    DAYS_AHEAD = 3

    def perform(days_ahead = DAYS_AHEAD)
      School.active.find_each do |school|
        Current.school = school

        FeeInvoice.unpaid.where(due_date: Date.current + days_ahead)
                  .includes(student: { guardians: :user }).find_each do |invoice|
          Notifier.deliver(event: "fee_due", to: invoice.student.contact_users, school:,
                           dedupe_key: "fee:#{invoice.id}",
                           values: { student: invoice.student.name, number: invoice.number,
                                     amount: "#{school.currency} #{invoice.balance.to_i}",
                                     due_date: invoice.due_date.to_fs(:long) })
        end
      end
    ensure
      Current.school = nil
    end
  end
end
