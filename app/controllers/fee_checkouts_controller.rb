class FeeCheckoutsController < ApplicationController
  before_action -> { authorize!("fees.read") }
  rescue_from Payments::Razorpay::NotConfigured, with: -> { redirect_back fallback_location: fees_path, alert: "Online payment is not set up for this school yet." }
  rescue_from Payments::Razorpay::Rejected, with: ->(e) { redirect_back fallback_location: fees_path, alert: e.message }

  def create
    invoices = FeeInvoice.where(id: params.require(:invoice_ids))
    @checkout = Payments::Razorpay.new.create_order(user: current_user, invoices:)
  end

  def confirm
    order = PaymentOrder.find_by!(id: params[:id], user: current_user)
    Payments::Razorpay.new.confirm(order, payment_id: params.require(:razorpay_payment_id),
                                          signature: params.require(:razorpay_signature))
    redirect_to fees_path, notice: "Payment of #{helpers.rupees(order.amount)} received. Thank you."
  end
end
