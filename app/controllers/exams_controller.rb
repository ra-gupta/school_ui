class ExamsController < ApplicationController
  before_action -> { authorize!("exams.read") },  only: [:index, :show]
  before_action -> { authorize!("exams.write") }, except: [:index, :show]
  before_action :set_exam, only: [:show, :edit, :update, :destroy]

  def index = @exams = Exam.where(academic_year: Current.academic_year).order(starts_on: :desc)

  def show
    @schedules = @exam.exam_schedules.includes(:section, :subject, :exam_results).order(:on_date)
    @schedule  = ExamSchedule.new(max_marks: 100, pass_marks: 33)
    @sections  = Section.includes(:grade).order("grades.level", :name)
    @subjects  = Subject.order(:name)
  end

  def new  = @exam = Exam.new(academic_year: Current.academic_year)
  def edit; end

  def create
    @exam = Exam.new(exam_params.merge(academic_year: Current.academic_year))
    @exam.save ? redirect_to(@exam, notice: "Exam created.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @exam.update(exam_params) ? redirect_to(@exam, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @exam.destroy
    redirect_to exams_path, notice: "Deleted."
  end

  private

  def set_exam = @exam = Exam.find(params[:id])
  def exam_params = params.expect(exam: [:name, :exam_type, :starts_on, :ends_on, :published])
end
