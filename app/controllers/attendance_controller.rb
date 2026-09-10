# Daily roster marking for one section. Bulk upsert so 40 students is one INSERT.
class AttendanceController < ApplicationController
  before_action -> { authorize!("attendance.read") },  only: :show
  before_action -> { authorize!("attendance.write") }, only: :update
  before_action :set_context

  def show
    @enrollments = @section ? @section.enrollments.active.includes(:student).order(:roll_no) : Enrollment.none
    @marked = Attendance.where(attendable_type: "Student", attendable_id: @enrollments.map(&:student_id), on_date: @date)
                        .index_by(&:attendable_id)
    @summary = Attendance.where(section: @section, on_date: @date).group(:status).count
  end

  def update
    rows = params.fetch(:attendance, {}).map do |student_id, status|
      { school_id: Current.school.id, academic_year_id: Current.academic_year&.id,
        attendable_type: "Student", attendable_id: student_id.to_i, section_id: @section.id,
        on_date: @date, status:, source: "manual", marked_by_id: current_user.id,
        created_at: Time.current, updated_at: Time.current }
    end
    if rows.any?
      Attendance.upsert_all(rows, unique_by: :idx_attendance_unique)
      Notifications::AbsenceJob.perform_later(@section.id, @date)
    end
    redirect_to attendance_path(section_id: @section.id, date: @date), notice: "#{rows.size} students marked."
  end

  private

  def set_context
    @date     = params[:date].presence&.to_date || Date.current
    @sections = Section.includes(:grade).order("grades.level", :name)
    @section  = @sections.find_by(id: params[:section_id]) || @sections.first
  end
end
