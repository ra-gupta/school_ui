class CreatePeopleAndFinanceModules < ActiveRecord::Migration[8.1]
  def change
    create_table :admission_enquiries do |t|
      t.references :school, null: false, foreign_key: true
      t.references :grade, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :student_name, null: false
      t.string :guardian_name
      t.string :phone
      t.string :email
      t.string :source
      t.string :status, default: "new", null: false
      t.date   :enquired_on, null: false
      t.date   :follow_up_on
      t.text   :notes
      t.timestamps
      t.index [ :school_id, :status ]
    end

    create_table :certificate_templates do |t|
      t.references :school, null: false, foreign_key: true
      t.string :name, null: false
      t.string :kind, default: "bonafide", null: false
      t.text   :body
      t.timestamps
    end

    create_table :issued_certificates do |t|
      t.references :school, null: false, foreign_key: true
      t.references :certificate_template, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :issued_by, foreign_key: { to_table: :users }
      t.string :number, null: false
      t.date   :issued_on, null: false
      t.text   :remarks
      t.timestamps
      t.index [ :school_id, :number ], unique: true
    end

    create_table :id_card_templates do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :audience, default: "student", null: false
      t.string  :orientation, default: "portrait", null: false
      t.string  :background_color, default: "#4f46e5", null: false
      t.jsonb   :fields, default: [], null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    create_table :payslips do |t|
      t.references :school, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true
      t.string  :period, null: false                  # "2026-09"
      t.decimal :basic,      precision: 12, scale: 2, default: 0, null: false
      t.decimal :allowances, precision: 12, scale: 2, default: 0, null: false
      t.decimal :deductions, precision: 12, scale: 2, default: 0, null: false
      t.decimal :net_pay,    precision: 12, scale: 2, default: 0, null: false
      t.integer :days_present
      t.string  :status, default: "draft", null: false
      t.date    :paid_on
      t.timestamps
      t.index [ :staff_id, :period ], unique: true
    end

    create_table :ledger_entries do |t|
      t.references :school, null: false, foreign_key: true
      t.references :recorded_by, foreign_key: { to_table: :users }
      t.string  :direction, default: "expense", null: false   # income | expense
      t.string  :category
      t.string  :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date    :on_date, null: false
      t.string  :payment_mode, default: "cash", null: false
      t.string  :reference
      t.timestamps
      t.index [ :school_id, :on_date ]
    end
  end
end
