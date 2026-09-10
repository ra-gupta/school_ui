# Super-admin school switcher + tenant management.
class SchoolsController < ApplicationController
  before_action :require_super_admin

  def index  = @schools = School.order(:name)
  def new    = @school = School.new
  def edit   = @school = School.find(params[:id])

  def create
    @school = School.new(school_params)
    @school.save ? redirect_to(schools_path, notice: "School created.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @school = School.find(params[:id])
    @school.update(school_params) ? redirect_to(schools_path, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  # Switch the super admin into a tenant.
  def enter
    session[:school_id] = School.active.find(params[:id]).id
    redirect_to root_path
  end

  def leave
    session.delete(:school_id)
    redirect_to schools_path
  end

  private

  def require_super_admin
    raise Forbidden unless current_user.super_admin?
  end

  def school_params
    params.expect(school: [ :name, :code, :subdomain, :email, :phone, :address, :city, :state,
                           :timezone, :currency, :locale, :primary_color, :active,
                           :subscription_ends_on, enabled_modules: [] ])
  end
end
