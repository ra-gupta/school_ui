# Marks entry: one row per enrolled student, saved in a single upsert.
class ExamResultsController < ApplicationController
  before_action -> { authorize!("exams.update") }
  before_action :set_schedule

  def edit
    @students = @schedule.section.enrollments.active.includes(:student).order(:roll_no).map(&:student)
    @results  = @schedule.exam_results.index_by(&:student_id)
  end

  def update
    rows = params.fetch(:results, {}).filter_map do |student_id, attrs|
      absent = attrs[:absent] == "1"
      next if !absent && attrs[:marks].blank?
      { exam_schedule_id: @schedule.id, student_id: student_id.to_i,
        marks: absent ? nil : attrs[:marks], absent:,
        created_at: Time.current, updated_at: Time.current }
    end
    ExamResult.upsert_all(rows, unique_by: :idx_result_unique) if rows.any?
    # upsert_all skips callbacks, so recompute the letter grade in one pass
    @schedule.exam_results.reload.each(&:save!)
    redirect_to @schedule.exam, notice: "#{rows.size} marks saved."
  end

  private

  def set_schedule = @schedule = ExamSchedule.find(params[:exam_schedule_id])
end
