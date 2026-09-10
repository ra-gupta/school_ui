module Api
  module V1
    # Token = the signed id of a regular Session row, so web and app sessions
    # are the same thing and revoking one revokes the other.
    class BaseController < ActionController::API
      class Forbidden < StandardError; end

      VERIFIER = ->(*) { Rails.application.message_verifier("api_session") }

      before_action :authenticate!
      before_action :set_tenant

      rescue_from Forbidden,                       with: -> { render_error("forbidden", :forbidden) }
      rescue_from ActiveRecord::RecordNotFound,     with: -> { render_error("not_found", :not_found) }
      rescue_from ActionController::ParameterMissing, with: ->(e) { render_error(e.message, :bad_request) }

      def self.token_for(session) = VERIFIER.call.generate(session.id)

      private

      def authenticate!
        token = request.headers["Authorization"].to_s.delete_prefix("Bearer ")
        id = VERIFIER.call.verified(token)
        Current.session = id && Session.find_by(id:)
        render_error("unauthorized", :unauthorized) unless Current.user&.active?
      end

      def set_tenant
        Current.school = Current.user.school
        Current.academic_year = Current.school&.current_academic_year
      end

      def current_user = Current.user
      def authorize!(permission)
        raise Forbidden unless current_user.can?(permission)
      end
      def render_error(message, status) = render(json: { error: message }, status:)

      def paginate(scope, per: 50)
        page = [params[:page].to_i, 1].max
        per  = [params[:per_page].to_i, per].max.clamp(1, 200)
        { page:, per_page: per, total: scope.limit(nil).offset(nil).count,
          data: scope.limit(per).offset((page - 1) * per) }
      end
    end
  end
end
