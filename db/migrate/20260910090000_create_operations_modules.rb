class CreateOperationsModules < ActiveRecord::Migration[8.1]
  def change
    # --- Library
    create_table :books do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :title, null: false
      t.string  :author
      t.string  :isbn
      t.string  :publisher
      t.string  :category
      t.string  :rack
      t.integer :copies, default: 1, null: false
      t.integer :available, default: 1, null: false
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
      t.index [:school_id, :isbn]
      t.index [:school_id, :title]
    end

    create_table :book_issues do |t|
      t.references :school, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.references :student, foreign_key: true
      t.references :staff, foreign_key: true
      t.date    :issued_on, null: false
      t.date    :due_on, null: false
      t.date    :returned_on
      t.decimal :fine, precision: 8, scale: 2, default: 0, null: false
      t.timestamps
      t.index [:school_id, :returned_on]
    end

    # --- Transport
    create_table :vehicles do |t|
      t.references :school, null: false, foreign_key: true
      t.references :driver, foreign_key: { to_table: :staffs }
      t.string  :registration_no, null: false
      t.string  :model
      t.integer :capacity, default: 40, null: false
      t.string  :gps_device_id
      t.date    :insurance_expires_on
      t.date    :fitness_expires_on
      t.string  :status, default: "active", null: false
      t.timestamps
      t.index [:school_id, :registration_no], unique: true
    end

    create_table :transport_routes do |t|
      t.references :school, null: false, foreign_key: true
      t.references :vehicle, foreign_key: true
      t.string  :name, null: false
      t.string  :start_point
      t.string  :end_point
      t.decimal :fare, precision: 10, scale: 2, default: 0, null: false
      t.timestamps
    end

    create_table :route_stops do |t|
      t.references :school, null: false, foreign_key: true
      t.references :transport_route, null: false, foreign_key: true
      t.string  :name, null: false
      t.time    :pickup_at
      t.time    :drop_at
      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    create_table :transport_assignments do |t|
      t.references :school, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :transport_route, null: false, foreign_key: true
      t.references :route_stop, foreign_key: true
      t.string  :direction, default: "both", null: false
      t.timestamps
      t.index [:student_id, :transport_route_id], unique: true
    end

    # Driver pings; one row per fix, read back as the live trail.
    create_table :vehicle_locations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.decimal  :latitude,  precision: 10, scale: 6, null: false
      t.decimal  :longitude, precision: 10, scale: 6, null: false
      t.decimal  :speed, precision: 6, scale: 2
      t.integer  :heading
      t.datetime :recorded_at, null: false
      t.timestamps
      t.index [:vehicle_id, :recorded_at]
    end

    # --- Hostel
    create_table :hostels do |t|
      t.references :school, null: false, foreign_key: true
      t.references :warden, foreign_key: { to_table: :staffs }
      t.string  :name, null: false
      t.string  :kind, default: "boys", null: false
      t.text    :address
      t.integer :capacity, default: 0, null: false
      t.timestamps
    end

    create_table :hostel_rooms do |t|
      t.references :school, null: false, foreign_key: true
      t.references :hostel, null: false, foreign_key: true
      t.string  :number, null: false
      t.string  :kind, default: "shared", null: false
      t.integer :capacity, default: 2, null: false
      t.decimal :rent, precision: 10, scale: 2, default: 0, null: false
      t.timestamps
      t.index [:hostel_id, :number], unique: true
    end

    create_table :hostel_allocations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :hostel_room, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.date   :from_on, null: false
      t.date   :to_on
      t.string :bed_no
      t.timestamps
      t.index [:student_id, :from_on]
    end

    # --- Inventory
    create_table :inventory_items do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :code
      t.string  :category
      t.string  :unit, default: "pcs", null: false
      t.integer :quantity, default: 0, null: false
      t.integer :reorder_level, default: 0, null: false
      t.decimal :unit_cost, precision: 10, scale: 2
      t.string  :store
      t.timestamps
      t.index [:school_id, :name]
    end

    create_table :stock_movements do |t|
      t.references :school, null: false, foreign_key: true
      t.references :inventory_item, null: false, foreign_key: true
      t.references :recorded_by, foreign_key: { to_table: :users }
      t.string  :direction, default: "in", null: false
      t.integer :quantity, null: false
      t.string  :reason
      t.date    :on_date, null: false
      t.timestamps
    end

    # --- Assets
    create_table :assets do |t|
      t.references :school, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :staffs }
      t.string  :name, null: false
      t.string  :code
      t.string  :category
      t.date    :purchased_on
      t.decimal :cost, precision: 12, scale: 2
      t.string  :location
      t.string  :condition, default: "good", null: false
      t.string  :status, default: "in_use", null: false
      t.date    :warranty_expires_on
      t.timestamps
      t.index [:school_id, :code]
    end

    # --- Front office
    create_table :visitors do |t|
      t.references :school, null: false, foreign_key: true
      t.references :meeting, foreign_key: { to_table: :staffs }
      t.string   :name, null: false
      t.string   :phone
      t.string   :purpose
      t.string   :pass_no
      t.integer  :party_size, default: 1, null: false
      t.datetime :in_at, null: false
      t.datetime :out_at
      t.timestamps
      t.index [:school_id, :in_at]
    end

    create_table :phone_logs do |t|
      t.references :school, null: false, foreign_key: true
      t.string   :caller_name
      t.string   :phone
      t.string   :direction, default: "incoming", null: false
      t.string   :purpose
      t.datetime :called_at, null: false
      t.text     :notes
      t.timestamps
    end

    create_table :postal_records do |t|
      t.references :school, null: false, foreign_key: true
      t.string :direction, default: "received", null: false
      t.string :reference_no
      t.string :from_name
      t.string :to_name
      t.date   :on_date, null: false
      t.text   :notes
      t.timestamps
    end

    # --- Gate pass
    create_table :gate_passes do |t|
      t.references :school, null: false, foreign_key: true
      t.references :student, foreign_key: true
      t.references :staff, foreign_key: true
      t.references :approved_by, foreign_key: { to_table: :users }
      t.string   :reason, null: false
      t.datetime :out_at, null: false
      t.datetime :in_at
      t.string   :status, default: "pending", null: false
      t.timestamps
      t.index [:school_id, :status]
    end

    # --- Health
    create_table :health_records do |t|
      t.references :school, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.date    :checked_on, null: false
      t.decimal :height_cm, precision: 5, scale: 1
      t.decimal :weight_kg, precision: 5, scale: 1
      t.string  :blood_pressure
      t.integer :pulse
      t.string  :vision
      t.text    :allergies
      t.text    :notes
      t.timestamps
      t.index [:student_id, :checked_on]
    end

    # --- CCTV
    create_table :cameras do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :location
      t.string  :stream_url
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    # --- Campus workers
    create_table :campus_workers do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :role
      t.string  :phone
      t.string  :shift
      t.decimal :daily_wage, precision: 10, scale: 2
      t.date    :joined_on
      t.string  :status, default: "active", null: false
      t.timestamps
    end
  end
end
