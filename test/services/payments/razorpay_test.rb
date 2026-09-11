require "test_helper"

# No network: the gateway's order call is stubbed, and signatures are computed
# with the test secret exactly as Razorpay computes them, so verification is
# exercised for real.
class Payments::RazorpayTest < ActiveSupport::TestCase
  KEY_ID = "rzp_test_key"
  SECRET = "rzp_test_secret"

  FakeOrder = Struct.new(:id)

  setup do
    ENV["RAZORPAY_KEY_ID"] = KEY_ID
    ENV["RAZORPAY_KEY_SECRET"] = SECRET
    ENV["RAZORPAY_WEBHOOK_SECRET"] = "whsec"

    Current.school = @school = School.create!(name: "Pay High", code: "PAY", subdomain: "pay-high")
    Current.academic_year = AcademicYear.create!(name: "2026-27", starts_on: "2026-04-01", ends_on: "2027-03-31", current: true)

    @parent = User.create!(school: @school, name: "Parent", kind: "parent", email_address: "p@pay.test", password: "password")
    guardian = Guardian.create!(name: "Parent", user: @parent)
    @kid1 = Student.create!(admission_no: "PAY1", first_name: "One")
    @kid2 = Student.create!(admission_no: "PAY2", first_name: "Two")
    [ @kid1, @kid2 ].each { Guardianship.create!(guardian:, student: it) }
    @stranger = Student.create!(admission_no: "PAY9", first_name: "Nine")

    @inv1 = invoice_for(@kid1, 2600)
    @inv2 = invoice_for(@kid2, 1400)
    @other = invoice_for(@stranger, 999)

    @order = with_fake_gateway { gateway.create_order(user: @parent, invoices: [ @inv1, @inv2 ]) }
  end

  teardown do
    Current.school = nil
    %w[RAZORPAY_KEY_ID RAZORPAY_KEY_SECRET RAZORPAY_WEBHOOK_SECRET].each { ENV.delete(it) }
  end

  test "one order covers several children's invoices and fixes the split up front" do
    order = PaymentOrder.find(@order[:payment_order_id])
    assert_equal 400_000, order.amount_paise
    assert_equal({ @inv1.id.to_s => 260_000, @inv2.id.to_s => 140_000 }, order.allocations)
    assert_equal KEY_ID, @order[:key_id]
    assert_nil @order[:key_secret], "the secret must never be in what the client gets"
  end

  test "refuses an invoice that is not this family's" do
    assert_raises(Payments::Razorpay::Rejected) do
      with_fake_gateway { gateway.create_order(user: @parent, invoices: [ @other ]) }
    end
  end

  test "a verified confirmation records one payment per invoice for the allocated amount" do
    order = PaymentOrder.find(@order[:payment_order_id])
    # A cash payment lands between order and confirm: the split must not move.
    @inv1.fee_payments.create!(amount: 100, method: "cash", paid_at: Time.current)

    gateway.confirm(order, payment_id: "pay_1", signature: sign(order.gateway_order_id, "pay_1"))

    assert order.reload.paid?
    assert_equal "pay_1", order.gateway_payment_id
    assert_equal 2600, @inv1.fee_payments.where(gateway: "razorpay").sum(:amount)
    assert_equal 1400, @inv2.fee_payments.where(gateway: "razorpay").sum(:amount)
    assert_equal "paid", @inv2.reload.status
  end

  test "confirming twice records the money once" do
    order = PaymentOrder.find(@order[:payment_order_id])
    sig = sign(order.gateway_order_id, "pay_2")
    2.times { gateway.confirm(order.reload, payment_id: "pay_2", signature: sig) }

    assert_equal 1, @inv1.fee_payments.where(gateway: "razorpay").count
    assert_equal 1, @inv2.fee_payments.where(gateway: "razorpay").count
  end

  test "a forged signature records nothing and marks the order failed" do
    order = PaymentOrder.find(@order[:payment_order_id])
    assert_raises(Payments::Razorpay::Rejected) do
      gateway.confirm(order, payment_id: "pay_3", signature: "not-a-real-signature")
    end
    assert_equal "failed", order.reload.status
    assert_equal 0, FeePayment.where(gateway: "razorpay").count
  end

  test "the webhook records a captured payment on its own" do
    order = PaymentOrder.find(@order[:payment_order_id])
    body = { event: "payment.captured",
             payload: { payment: { entity: { id: "pay_wh", order_id: order.gateway_order_id } } } }.to_json
    signature = OpenSSL::HMAC.hexdigest("SHA256", "whsec", body)

    assert_equal :recorded, gateway.handle_webhook(body, signature)
    assert order.reload.paid?
    assert_equal 2, FeePayment.where(gateway: "razorpay").count
  end

  test "the webhook rejects a body whose signature does not match" do
    assert_raises(SecurityError) { gateway.handle_webhook("{}", "bad") }
  end

  private

  def gateway = Payments::Razorpay.new

  # Only the order call touches the network; swap it for the duration and put
  # the real one back, whatever happens inside.
  def with_fake_gateway
    counter = 0
    real = Razorpay::Order.method(:create)
    Razorpay::Order.define_singleton_method(:create) { |_| FakeOrder.new("order_#{counter += 1}") }
    yield
  ensure
    Razorpay::Order.define_singleton_method(:create, real)
  end

  def sign(order_id, payment_id) = OpenSSL::HMAC.hexdigest("SHA256", SECRET, "#{order_id}|#{payment_id}")

  def invoice_for(student, amount)
    inv = FeeInvoice.create!(student:, academic_year: Current.academic_year, period: "2026-09",
                             issue_date: Date.current, due_date: Date.current + 10)
    inv.fee_invoice_items.create!(description: "Tuition", amount:)
    inv.refresh_totals!
    inv
  end
end
