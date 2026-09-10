class DashboardController < ApplicationController
  def show
    return render :super_admin if current_user.super_admin? && current_school.nil?

    @today    = Date.current
    @students = Student.active.count
    @staff    = Staff.active.count
    @sections = Section.count

    @attendance = Attendance.where(attendable_type: "Student", on_date: @today).group(:status).count
    @marked     = @attendance.values.sum

    @collected_month = payments_between(@today.all_month)
    @collected_prev  = payments_between((@today << 1).all_month)
    @collected_today = payments_between(@today.all_day)
    @outstanding     = FeeInvoice.unpaid.sum("total + fine - discount - paid")
    @overdue_count   = FeeInvoice.overdue.count

    @collections_by_day = FeePayment.where(paid_at: 29.days.ago.beginning_of_day.., status: "success")
                                    .group("date(paid_at)").sum(:amount)
    @notices  = Notice.live.limit(4)
    @payments = FeePayment.includes(fee_invoice: :student).order(paid_at: :desc).limit(6)
  end

  private

  def payments_between(range) = FeePayment.where(paid_at: range, status: "success").sum(:amount)
end
