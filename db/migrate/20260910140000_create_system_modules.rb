class CreateSystemModules < ActiveRecord::Migration[8.1]
  def change
    create_table :compliance_documents do |t|
      t.references :school, null: false, foreign_key: true
      t.references :owner, foreign_key: { to_table: :staffs }
      t.string :title, null: false
      t.string :category
      t.string :authority
      t.string :reference_no
      t.date   :issued_on
      t.date   :expires_on
      t.string :status, default: "valid", null: false
      t.text   :notes
      t.timestamps
      t.index [ :school_id, :expires_on ]
    end

    create_table :support_tickets do |t|
      t.references :school, null: false, foreign_key: true
      t.references :raised_by, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string   :subject, null: false
      t.text     :body
      t.string   :category
      t.string   :priority, default: "normal", null: false
      t.string   :status, default: "open", null: false
      t.datetime :resolved_at
      t.timestamps
      t.index [ :school_id, :status ]
    end

    create_table :backup_runs do |t|
      t.references :school, null: false, foreign_key: true
      t.string   :destination, default: "local", null: false   # local r2 b2 telegram
      t.string   :kind, default: "full", null: false           # full database files
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.bigint   :size_bytes
      t.string   :status, default: "running", null: false
      t.string   :error
      t.timestamps
      t.index [ :school_id, :started_at ]
    end

    create_table :stored_files do |t|
      t.references :school, null: false, foreign_key: true
      t.references :uploaded_by, foreign_key: { to_table: :users }
      t.string  :title, null: false
      t.string  :folder, default: "General", null: false
      t.string  :visibility, default: "staff", null: false
      t.text    :description
      t.timestamps
      t.index [ :school_id, :folder ]
    end
  end
end
