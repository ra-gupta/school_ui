class ExamSchedulesController < ApplicationController
  before_action -> { authorize!("exams.write") }

  def create
    exam = Exam.find(params[:exam_id])
    schedule = exam.exam_schedules.new(params.expect(exam_schedule: [ :section_id, :subject_id, :on_date, :starts_at, :ends_at, :max_marks, :pass_marks, :room ]))
    redirect_to exam, notice: schedule.save ? "Paper added." : nil, alert: schedule.errors.full_messages.to_sentence.presence
  end

  def destroy
    schedule = ExamSchedule.find(params[:id])
    exam = schedule.exam
    schedule.destroy
    redirect_to exam, notice: "Paper removed."
  end
end
