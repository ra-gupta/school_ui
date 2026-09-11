module Api
  module V1
    # Online fee payment from the app. Three calls: create an order for one or
    # more invoices, hand the returned params to Razorpay Checkout on the
    # device, then confirm with what Checkout returns. The webhook covers the
    # case where the app dies between paying and confirming.
    class PaymentsController < BaseController
      rescue_from Payments::Razorpay::NotConfigured, with: -> { render_error("payments_not_configured", :service_unavailable) }
      rescue_from Payments::Razorpay::Rejected, with: ->(e) { render_error(e.message, :unprocessable_entity) }

      def create
        invoices = FeeInvoice.where(id: params.require(:invoice_ids))
        render json: Payments::Razorpay.new.create_order(user: current_user, invoices:), status: :created
      end

      def confirm
        order = PaymentOrder.find_by!(id: params[:id], user: current_user)
        Payments::Razorpay.new.confirm(order, payment_id: params.require(:payment_id), signature: params.require(:signature))
        render json: serialize(order.reload)
      end

      def show = render(json: serialize(PaymentOrder.find_by!(id: params[:id], user: current_user)))

      private

      def serialize(order)
        { id: order.id, status: order.status, amount: order.amount, currency: order.currency,
          paid_at: order.paid_at, payment_id: order.gateway_payment_id,
          invoices: order.invoices.map { { id: it.id, number: it.number, balance: it.balance.to_f, status: it.status } } }
      end
    end
  end
end
