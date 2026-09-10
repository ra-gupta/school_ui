class ApplicationController < ActionController::Base
  class Forbidden < StandardError; end

  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_tenant
  before_action :require_school
  helper_method :current_user, :current_school, :current_academic_year, :nav_modules

  rescue_from Forbidden, with: :deny
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_user          = Current.user
  def current_school        = Current.school
  def current_academic_year = Current.academic_year

  # Tenant comes from the subdomain when there is one (white-label domains),
  # otherwise from the signed-in user. Super admins can switch schools.
  def set_tenant
    sub = request.subdomains.first
    Current.school =
      if sub.present? && sub != "www"
        School.active.find_by(subdomain: sub)
      elsif Current.user&.super_admin?
        School.active.find_by(id: session[:school_id])
      else
        Current.user&.school
      end
    Current.academic_year = Current.school&.current_academic_year
  end

  def require_school
    return if Current.school || Current.user.nil? || Current.user.super_admin?
    terminate_session
    redirect_to new_session_path, alert: "Your account isn't attached to a school."
  end

  def authorize!(permission)
    raise Forbidden unless current_user&.can?(permission)
  end

  def require_module!(key)
    raise Forbidden unless Current.school&.module_enabled?(key)
  end

  # Sidebar entries: enabled for this school AND permitted for this user.
  def nav_modules
    return [] unless current_school
    SchoolModule.all.select { |m| current_school.module_enabled?(m.key) && current_user.can?("#{m.key}.read") }
  end

  # 6 lines beats a pagination gem.
  def paginate(scope, per: AppConfig[:per_page])
    @page  = [ params[:page].to_i, 1 ].max
    @total = scope.limit(nil).offset(nil).count
    @pages = (@total / per.to_f).ceil
    scope.limit(per).offset((@page - 1) * per)
  end

  def deny
    respond_to do |f|
      f.html { redirect_back fallback_location: root_path, alert: "You don't have permission to do that." }
      f.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end

  def not_found
    respond_to do |f|
      f.html { redirect_back fallback_location: root_path, alert: "Not found." }
      f.json { render json: { error: "not_found" }, status: :not_found }
    end
  end
end
