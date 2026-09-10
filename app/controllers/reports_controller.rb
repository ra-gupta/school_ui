require "csv"

# Reports & Export. Every figure here is computed in SQL rather than loaded and
# summed in Ruby — these run over the whole school, not a page of it.
class ReportsController < ApplicationController
  before_action -> { authorize!("reports.read") }

  def show
    @from = params[:from].presence&.to_date || 90.days.ago.to_date
    @to   = params[:to].presence&.to_date || Date.current

    @collection_by_month = FeePayment.where(paid_at: @from.beginning_of_day..@to.end_of_day, status: "success")
                                     .group(Arel.sql("to_char(paid_at, 'YYYY-MM')")).sum(:amount)

    @strength_by_grade = Enrollment.active.joins(section: :grade)
                                   .group(Arel.sql("grades.name"), Arel.sql("grades.level"))
                                   .count.transform_keys(&:first)

    @attendance_by_status = Attendance.where(attendable_type: "Student", on_date: @from..@to)
                                      .group(:status).count

    @dues_by_grade = FeeInvoice.unpaid.joins(student: { enrollments: { section: :grade } })
                               .group(Arel.sql("grades.name"))
                               .sum(Arel.sql("fee_invoices.total + fee_invoices.fine - fee_invoices.discount - fee_invoices.paid"))

    @ledger = LedgerEntry.where(on_date: @from..@to).group(:direction).sum(:amount)

    respond_to do |format|
      format.html
      format.csv { send_data collections_csv, filename: "fee-collection-#{@from}-to-#{@to}.csv" }
    end
  end

  private

  def collections_csv
    CSV.generate(headers: true) do |csv|
      csv << [ "Receipt", "Date", "Student", "Admission no", "Class", "Method", "Amount" ]
      FeePayment.includes(fee_invoice: { student: { enrollments: { section: :grade } } })
                .where(paid_at: @from.beginning_of_day..@to.end_of_day, status: "success")
                .find_each do |payment|
        student = payment.fee_invoice.student
        csv << [ payment.id, payment.paid_at.to_date, student.name, student.admission_no,
                student.section&.full_name, payment.method, payment.amount ]
      end
    end
  end
end
