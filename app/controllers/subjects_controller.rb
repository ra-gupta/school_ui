class SubjectsController < ApplicationController
  before_action -> { authorize!("academics.write") }

  def create
    record = Subject.new(record_params)
    redirect_to academics_path, notice: record.save ? "Saved." : nil, alert: record.errors.full_messages.to_sentence.presence
  end

  def edit = @record = Subject.find(params[:id])

  def update
    @record = Subject.find(params[:id])
    @record.update(record_params) ? redirect_to(academics_path, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    Subject.find(params[:id]).destroy
    redirect_to academics_path, notice: "Removed."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to academics_path, alert: "Still in use — remove what depends on it first."
  end

  private

  def record_params = params.expect(subject: [ :name, :code, :subject_type, :grade_id ])
end
