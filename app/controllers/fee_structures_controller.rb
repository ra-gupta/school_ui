class FeeStructuresController < ApplicationController
  before_action -> { authorize!("fees.read") },  only: :index
  before_action -> { authorize!("fees.write") }, except: :index

  def index
    @structures = FeeStructure.where(academic_year: Current.academic_year)
                              .includes(:grade, :fee_head).order("grades.level").references(:grades)
    @structure = FeeStructure.new(academic_year: Current.academic_year)
  end

  def create
    @structure = FeeStructure.new(structure_params.merge(academic_year: Current.academic_year))
    @structure.save ? redirect_to(fee_structures_path, notice: "Added.") : redirect_to(fee_structures_path, alert: @structure.errors.full_messages.to_sentence)
  end

  def edit = @structure = FeeStructure.find(params[:id])

  def update
    @structure = FeeStructure.find(params[:id])
    @structure.update(structure_params) ? redirect_to(fee_structures_path, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    FeeStructure.find(params[:id]).destroy
    redirect_to fee_structures_path, notice: "Removed."
  end

  private

  def structure_params = params.expect(fee_structure: [:grade_id, :fee_head_id, :amount, :frequency, :due_day])
end
