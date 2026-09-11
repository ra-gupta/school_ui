# Gateway callbacks. No session, no CSRF — authenticity is the HMAC signature
# on the body, verified by the gateway service, and nothing else.
class WebhooksController < ActionController::API
  def razorpay
    result = Payments::Razorpay.new.handle_webhook(request.raw_post, request.headers["X-Razorpay-Signature"].to_s)
    head result == :recorded ? :ok : :accepted
  rescue SecurityError
    head :bad_request
  rescue Payments::Razorpay::NotConfigured
    head :service_unavailable
  end
end
