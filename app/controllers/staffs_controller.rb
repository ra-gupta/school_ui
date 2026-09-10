class StaffsController < ApplicationController
  before_action -> { authorize!("hr.read") },  only: [:index, :show]
  before_action -> { authorize!("hr.write") }, except: [:index, :show]
  before_action :set_staff, only: [:show, :edit, :update, :destroy]

  def index
    scope = Staff.where(status: params[:status].presence || "active")
    scope = scope.where(department_id: params[:department_id]) if params[:department_id].present?
    scope = scope.where("first_name ILIKE :q OR last_name ILIKE :q OR employee_no ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @staffs = paginate(scope.includes(:department).order(:first_name))
    @departments = Department.order(:name)
  end

  def show
    @attendance = @staff.attendances.where(on_date: 30.days.ago..).order(on_date: :desc)
    @sections   = @staff.sections.includes(:grade)
  end

  def new  = @staff = Staff.new(joining_date: Date.current, status: "active")
  def edit; end

  def create
    @staff = Staff.new(staff_params)
    @staff.save ? redirect_to(@staff, notice: "Staff added.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @staff.update(staff_params) ? redirect_to(@staff, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @staff.update!(status: "inactive")
    redirect_to staffs_path, notice: "Marked inactive."
  end

  private

  def set_staff = @staff = Staff.find(params[:id])

  def staff_params
    params.expect(staff: [:employee_no, :first_name, :last_name, :designation, :department_id, :joining_date,
                          :date_of_birth, :gender, :phone, :email, :qualification, :address,
                          :basic_salary, :biometric_id, :status])
  end
end
