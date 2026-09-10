class CreateAttendanceAndFees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, foreign_key: true
      t.references :attendable, polymorphic: true, null: false
      t.references :section, foreign_key: true
      t.references :marked_by, foreign_key: { to_table: :users }
      t.date    :on_date, null: false
      t.string  :status, null: false, default: "present" # present absent late half_day leave holiday
      t.string  :source, null: false, default: "manual"  # manual biometric qr app
      t.time    :check_in
      t.time    :check_out
      t.string  :remarks
      t.timestamps
      t.index [ :attendable_type, :attendable_id, :on_date ], unique: true, name: "idx_attendance_unique"
      t.index [ :school_id, :on_date ]
    end

    create_table :biometric_devices do |t|
      t.references :school, null: false, foreign_key: true
      t.string   :serial_number, null: false
      t.string   :name
      t.string   :ip_address
      t.string   :location
      t.datetime :last_seen_at
      t.boolean  :active, default: true, null: false
      t.timestamps
      t.index :serial_number, unique: true
    end

    create_table :biometric_punches do |t|
      t.references :school, null: false, foreign_key: true
      t.references :biometric_device, foreign_key: true
      t.string   :biometric_id, null: false
      t.datetime :punched_at, null: false
      t.integer  :punch_state
      t.integer  :verify_mode
      t.boolean  :processed, default: false, null: false
      t.timestamps
      t.index [ :biometric_device_id, :biometric_id, :punched_at ], unique: true, name: "idx_punch_dedupe"
    end

    create_table :fee_heads do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :code
      t.timestamps
      t.index [ :school_id, :name ], unique: true
    end

    create_table :fee_structures do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true
      t.references :fee_head, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string  :frequency, default: "monthly", null: false # monthly quarterly annual one_time
      t.integer :due_day, default: 10, null: false
      t.timestamps
      t.index [ :academic_year_id, :grade_id, :fee_head_id ], unique: true, name: "idx_fee_structure_unique"
    end

    create_table :fee_invoices do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string  :number, null: false
      t.string  :period                           # "2026-04" / "Q1" / "annual"
      t.date    :issue_date, null: false
      t.date    :due_date, null: false
      t.decimal :total,    precision: 12, scale: 2, default: 0, null: false
      t.decimal :discount, precision: 12, scale: 2, default: 0, null: false
      t.decimal :fine,     precision: 12, scale: 2, default: 0, null: false
      t.decimal :paid,     precision: 12, scale: 2, default: 0, null: false
      t.string  :status, default: "unpaid", null: false # unpaid partial paid cancelled
      t.timestamps
      t.index [ :school_id, :number ], unique: true
      t.index [ :student_id, :status ]
    end

    create_table :fee_invoice_items do |t|
      t.references :fee_invoice, null: false, foreign_key: true
      t.references :fee_head, foreign_key: true
      t.string  :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.timestamps
    end

    create_table :fee_payments do |t|
      t.references :school, null: false, foreign_key: true
      t.references :fee_invoice, null: false, foreign_key: true
      t.references :received_by, foreign_key: { to_table: :users }
      t.decimal  :amount, precision: 12, scale: 2, null: false
      t.string   :method, default: "cash", null: false # cash upi card cheque online
      t.string   :reference
      t.string   :gateway
      t.string   :gateway_ref
      t.string   :status, default: "success", null: false
      t.datetime :paid_at, null: false
      t.timestamps
      t.index [ :school_id, :paid_at ]
    end
  end
end
