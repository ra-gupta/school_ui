class StudentsController < ApplicationController
  before_action :authorize_read, only: [:index, :show]
  before_action :authorize_write, except: [:index, :show]
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    scope = Student.search(params[:q]).where(status: params[:status].presence || "active")
    scope = scope.joins(:enrollments).where(enrollments: { section_id: params[:section_id] }) if params[:section_id].present?
    @students = paginate(scope.includes(enrollments: { section: :grade }).order(:first_name))
    @sections = Section.includes(:grade).order("grades.level", :name)
  end

  def show
    @enrollment  = @student.current_enrollment
    @attendance  = @student.attendances.where(on_date: 30.days.ago..).order(on_date: :desc)
    @invoices    = @student.fee_invoices.order(issue_date: :desc)
    @results     = @student.exam_results.includes(exam_schedule: [:subject, :exam])
  end

  def new
    @student = Student.new(admission_date: Date.current, status: "active")
    @student.guardians.build
  end

  def edit
    @student.guardians.build if @student.guardians.empty?
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      enroll!(@student)
      redirect_to @student, notice: "Student admitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      enroll!(@student)
      redirect_to @student, notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.update!(status: "left")
    redirect_to students_path, notice: "Marked as left."
  end

  private

  def set_student     = @student = Student.find(params[:id])
  def authorize_read  = authorize!("students.read")
  def authorize_write = authorize!("students.write")

  def enroll!(student)
    section_id = params[:section_id].presence or return
    enrollment = student.enrollments.find_or_initialize_by(academic_year: Current.academic_year)
    enrollment.update!(section_id:, roll_no: params[:roll_no])
  end

  def student_params
    params.expect(student: [:admission_no, :first_name, :last_name, :date_of_birth, :gender, :blood_group,
                            :phone, :email, :address, :admission_date, :status, :house, :religion,
                            :category, :national_id, :biometric_id, :previous_school, :notes,
                            guardians_attributes: [[:id, :name, :relation, :phone, :email, :occupation, :_destroy]]])
  end
end
