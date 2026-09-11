class CreatePaymentOrders < ActiveRecord::Migration[8.1]
  def change
    # One checkout may settle several invoices — a parent paying for two
    # children at once — so the order is its own record, and the split into
    # per-invoice payments happens only once the gateway confirms it.
    create_table :payment_orders do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string  :gateway, null: false, default: "razorpay"
      t.string  :gateway_order_id, null: false
      t.string  :gateway_payment_id
      t.integer :amount_paise, null: false
      t.string  :currency, null: false, default: "INR"
      # invoice id => paise charged for it, fixed when the order is created.
      # The split is recorded from this, never from a balance read later.
      t.jsonb   :allocations, null: false, default: {}
      t.string  :status, null: false, default: "created"   # created paid failed
      t.datetime :paid_at
      t.string :failure_reason
      t.timestamps
      t.index :gateway_order_id, unique: true
      t.index :gateway_payment_id, unique: true, where: "gateway_payment_id IS NOT NULL"
      t.index [ :user_id, :created_at ]
    end

    # A gateway payment must be recorded exactly once, however many times the
    # confirmation arrives — the client callback and the webhook both deliver it.
    add_index :fee_payments, [ :gateway, :gateway_ref ], unique: true, where: "gateway_ref IS NOT NULL",
              name: "idx_fee_payment_gateway_once"
  end
end
