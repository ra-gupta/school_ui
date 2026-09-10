class CreateAcademics < ActiveRecord::Migration[8.1]
  def change
    create_table :timetable_slots do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :staff, foreign_key: true
      t.integer :weekday, null: false            # 0 = Sunday
      t.time    :starts_at, null: false
      t.time    :ends_at, null: false
      t.string  :room
      t.timestamps
      t.index [ :section_id, :weekday, :starts_at ], name: "idx_slot_unique"
    end

    create_table :exams do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.string  :name, null: false
      t.string  :exam_type, default: "term", null: false
      t.date    :starts_on
      t.date    :ends_on
      t.boolean :published, default: false, null: false
      t.timestamps
    end

    create_table :exam_schedules do |t|
      t.references :exam, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.date    :on_date
      t.time    :starts_at
      t.time    :ends_at
      t.decimal :max_marks,  precision: 6, scale: 2, default: 100, null: false
      t.decimal :pass_marks, precision: 6, scale: 2, default: 33,  null: false
      t.string  :room
      t.timestamps
      t.index [ :exam_id, :section_id, :subject_id ], unique: true, name: "idx_exam_schedule_unique"
    end

    create_table :exam_results do |t|
      t.references :exam_schedule, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.decimal :marks, precision: 6, scale: 2
      t.string  :grade
      t.boolean :absent, default: false, null: false
      t.string  :remarks
      t.timestamps
      t.index [ :exam_schedule_id, :student_id ], unique: true, name: "idx_result_unique"
    end

    create_table :homeworks do |t|
      t.references :school, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :staff, foreign_key: true
      t.string  :title, null: false
      t.text    :description
      t.date    :assigned_on, null: false
      t.date    :due_on
      t.timestamps
      t.index [ :section_id, :due_on ]
    end

    create_table :homework_submissions do |t|
      t.references :homework, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.text     :content
      t.datetime :submitted_at
      t.string   :status, default: "pending", null: false
      t.decimal  :marks, precision: 6, scale: 2
      t.string   :feedback
      t.timestamps
      t.index [ :homework_id, :student_id ], unique: true
    end

    create_table :notices do |t|
      t.references :school, null: false, foreign_key: true
      t.references :section, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string   :title, null: false
      t.text     :body
      t.string   :audience, default: "all", null: false # all staff parents students section
      t.datetime :published_at
      t.date     :expires_on
      t.timestamps
      t.index [ :school_id, :published_at ]
    end
  end
end
