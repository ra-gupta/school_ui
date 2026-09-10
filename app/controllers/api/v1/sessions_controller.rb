module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate!, :set_tenant, only: :create
      rate_limit to: 10, within: 3.minutes, only: :create,
                 with: -> { render json: { error: "too_many_attempts" }, status: :too_many_requests }

      def create
        # `login` is an email address or a mobile number; email_address is kept
        # so an app built against the earlier shape keeps working.
        user = User.authenticate_by_login(params[:login] || params[:email_address], params[:password])
        return render_error("invalid_credentials", :unauthorized) unless user

        session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
        render json: { token: self.class.token_for(session), user: UsersController.profile(user) }, status: :created
      end

      def destroy
        Current.session.destroy
        head :no_content
      end
    end
  end
end
