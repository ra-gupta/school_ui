class FeePaymentsController < ApplicationController
  before_action -> { authorize!("fees.collect") }

  def create
    invoice = FeeInvoice.find(params[:fee_invoice_id])
    payment = invoice.fee_payments.new(payment_params.merge(received_by: current_user))
    if payment.save
      redirect_to invoice, notice: "Receipt #{payment.id} · #{helpers.number_to_currency(payment.amount, unit: "₹")} received."
    else
      redirect_to invoice, alert: payment.errors.full_messages.to_sentence
    end
  end

  def destroy
    payment = FeePayment.find(params[:id])
    invoice = payment.fee_invoice
    payment.destroy!
    invoice.refresh_totals!
    redirect_to invoice, notice: "Payment reversed."
  end

  private

  def payment_params = params.expect(fee_payment: [:amount, :method, :reference, :paid_at])
end
