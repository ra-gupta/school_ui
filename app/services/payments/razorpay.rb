module Payments
  # Online fee payment through Razorpay.
  #
  # The money-critical rule: the client never tells us it paid. It tells us an
  # order and payment id, and we verify the gateway's HMAC signature over them
  # with our secret before a rupee is recorded. The webhook is verified the
  # same way and runs the same confirm, so whichever arrives first records the
  # payment and the other finds it already done.
  class Razorpay
    class NotConfigured < StandardError; end
    class Rejected < StandardError; end

    def self.configured? = ENV["RAZORPAY_KEY_ID"].present? && ENV["RAZORPAY_KEY_SECRET"].present?

    def initialize
      raise NotConfigured, "set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET" unless self.class.configured?
      ::Razorpay.setup(ENV.fetch("RAZORPAY_KEY_ID"), ENV.fetch("RAZORPAY_KEY_SECRET"))
    end

    # One order for any number of this person's own invoices. Returns what the
    # app's checkout needs; the secret never leaves the server.
    def create_order(user:, invoices:)
      invoices = Array(invoices).reject { it.balance <= 0 }
      raise Rejected, "nothing to pay" if invoices.empty?
      raise Rejected, "invoice does not belong to you" unless owns_all?(user, invoices)

      allocations = invoices.to_h { [ it.id.to_s, (it.balance * 100).round ] }
      paise = allocations.values.sum
      school = Current.school
      remote = ::Razorpay::Order.create(
        amount: paise, currency: school.currency,
        receipt: "sch#{school.id}-u#{user.id}-#{Time.current.to_i}",
        notes: { school: school.code, invoices: invoices.map(&:number).join(",") }
      )

      order = PaymentOrder.create!(user:, gateway_order_id: remote.id, amount_paise: paise,
                                   currency: school.currency, allocations:)
      checkout_params(order, user)
    end

    # Called with what Razorpay Checkout hands back to the client. Idempotent.
    def confirm(order, payment_id:, signature:)
      return order if order.paid?

      ::Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: order.gateway_order_id, razorpay_payment_id: payment_id, razorpay_signature: signature
      )
      record!(order, payment_id)
    rescue SecurityError
      order.update!(status: "failed", failure_reason: "signature mismatch")
      raise Rejected, "payment could not be verified"
    end

    # Razorpay posts here independently of the app. Verified against the
    # webhook secret, which is a different secret from the API key.
    def handle_webhook(body, signature)
      ::Razorpay::Utility.verify_webhook_signature(body, signature, ENV.fetch("RAZORPAY_WEBHOOK_SECRET"))
      event = JSON.parse(body)
      return :ignored unless event["event"] == "payment.captured"

      payment = event.dig("payload", "payment", "entity")
      order = PaymentOrder.unscoped.find_by(gateway_order_id: payment["order_id"]) or return :unknown_order
      Current.school = order.school
      record!(order, payment["id"])
      :recorded
    ensure
      Current.school = nil
    end

    private

    def owns_all?(user, invoices)
      mine = user.student ? [ user.student.id ] : user.guardian&.students&.ids.to_a
      invoices.all? { mine.include?(it.student_id) }
    end

    # The split: one gateway payment becomes one FeePayment per invoice. The
    # unique index on (gateway, gateway_ref) makes a repeat a no-op rather
    # than a double credit.
    def record!(order, payment_id)
      PaymentOrder.transaction do
        order.invoices.lock.each do |invoice|
          invoice.fee_payments.create!(
            amount: order.allocation_for(invoice), method: "online", gateway: "razorpay",
            gateway_ref: "#{payment_id}:#{invoice.id}", reference: payment_id,
            received_by: order.user, paid_at: Time.current, status: "success"
          )
        rescue ActiveRecord::RecordNotUnique
          next
        end
        order.update!(status: "paid", gateway_payment_id: payment_id, paid_at: Time.current)
      end
      order
    end

    def checkout_params(order, user)
      {
        order_id: order.gateway_order_id, key_id: ENV.fetch("RAZORPAY_KEY_ID"),
        amount: order.amount_paise, currency: order.currency,
        name: Current.school.name, description: "School fees",
        prefill: { name: user.name, email: user.email_address, contact: user.phone }.compact,
        theme: { color: Current.school.primary_color },
        payment_order_id: order.id
      }
    end
  end
end
