# Generic HTML CRUD for any Manageable model. Subclasses declare the model and
# inherit these views from app/views/resource/ via Rails' view inheritance.
class ResourceController < ApplicationController
  class_attribute :model
  class_attribute :tabs, default: {}   # label => path, rendered above the table

  before_action :authorize_read,  only: [ :index, :show ]
  before_action :authorize_write, except: [ :index, :show ]
  before_action :set_record, only: [ :show, :edit, :update, :destroy ]

  def index
    scope = model.all
    scope = apply_search(scope)
    resource_config[:fields].select(&:belongs_to?).each do |f|
      scope = scope.where(f.key => params[f.key]) if params[f.key].present?
    end
    @records = paginate(scope.order(resource_config[:order]), per: resource_config[:per_page])
  end

  def show = redirect_to(action: :edit)
  def new  = @record = model.new
  def edit; end

  def create
    @record = model.new(record_params)
    @record.save ? redirect_to({ action: :index }, notice: "Saved.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @record.update(record_params) ? redirect_to({ action: :index }, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @record.destroy
    redirect_to({ action: :index }, notice: "Removed.")
  rescue ActiveRecord::InvalidForeignKey
    redirect_to({ action: :index }, alert: "Still in use — remove what depends on it first.")
  end

  helper_method :resource_config, :resource_title, :tabs, :model

  private

  def resource_config = model.manage_config
  def resource_title = SchoolModule[resource_config[:module_key]]&.name || model.model_name.human.pluralize
  def set_record = @record = model.find(params[:id])
  def authorize_read  = authorize!("#{resource_config[:module_key]}.read")
  def authorize_write = authorize!("#{resource_config[:module_key]}.write")
  def record_params = params.expect(model.model_name.param_key.to_sym => model.permitted_params)

  def apply_search(scope)
    return scope if params[:q].blank? || resource_config[:search].empty?
    clause = resource_config[:search].map { "#{model.table_name}.#{it} ILIKE :q" }.join(" OR ")
    scope.where(clause, q: "%#{params[:q]}%")
  end
end
