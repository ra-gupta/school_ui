class HomeworksController < ApplicationController
  before_action -> { authorize!("homework.read") },  only: [:index, :show]
  before_action -> { authorize!("homework.write") }, except: [:index, :show]
  before_action :set_homework, only: [:show, :edit, :update, :destroy]

  def index
    scope = Homework.includes(:section, :subject, :staff)
    scope = scope.where(section_id: params[:section_id]) if params[:section_id].present?
    @homeworks = paginate(scope.order(assigned_on: :desc))
    @sections  = Section.includes(:grade).order("grades.level", :name)
  end

  def show = @submissions = @homework.homework_submissions.includes(:student)
  def new  = @homework = Homework.new(assigned_on: Date.current, due_on: 3.days.from_now.to_date, staff: current_user.staff)
  def edit; end

  def create
    @homework = Homework.new(homework_params)
    @homework.save ? redirect_to(@homework, notice: "Homework assigned.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @homework.update(homework_params) ? redirect_to(@homework, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @homework.destroy
    redirect_to homeworks_path, notice: "Deleted."
  end

  private

  def set_homework = @homework = Homework.find(params[:id])
  def homework_params = params.expect(homework: [:section_id, :subject_id, :staff_id, :title, :description, :assigned_on, :due_on])
end
