class CreateAcademicModules < ActiveRecord::Migration[8.1]
  def change
    # --- Online exams (CBT)
    create_table :online_tests do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :grade, foreign_key: true
      t.references :staff, foreign_key: true
      t.string   :name, null: false
      t.text     :instructions
      t.integer  :duration_minutes, default: 30, null: false
      t.datetime :opens_at
      t.datetime :closes_at
      t.decimal  :total_marks, precision: 6, scale: 2, default: 0, null: false
      t.decimal  :pass_marks,  precision: 6, scale: 2, default: 0, null: false
      t.boolean  :shuffle_questions, default: true, null: false
      t.string   :status, default: "draft", null: false
      t.timestamps
      t.index [ :school_id, :status ]
    end

    create_table :test_questions do |t|
      t.references :school, null: false, foreign_key: true
      t.references :online_test, null: false, foreign_key: true
      t.text    :prompt, null: false
      t.string  :kind, default: "mcq", null: false        # mcq true_false short
      t.string  :options, array: true, default: [], null: false
      t.string  :answer
      t.decimal :marks, precision: 6, scale: 2, default: 1, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
      t.index [ :online_test_id, :position ]
    end

    create_table :test_attempts do |t|
      t.references :school, null: false, foreign_key: true
      t.references :online_test, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :submitted_at
      t.decimal  :score, precision: 6, scale: 2
      t.string   :status, default: "in_progress", null: false
      t.jsonb    :answers, default: {}, null: false
      t.timestamps
      t.index [ :online_test_id, :student_id ], unique: true
    end

    # --- Lesson planner
    create_table :lesson_plans do |t|
      t.references :school, null: false, foreign_key: true
      t.references :section, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :staff, foreign_key: true
      t.date   :week_of, null: false
      t.string :topic, null: false
      t.text   :objectives
      t.text   :activities
      t.text   :resources
      t.string :status, default: "planned", null: false
      t.timestamps
      t.index [ :school_id, :week_of ]
    end

    # --- Competency-based assessment (CBC)
    create_table :competencies do |t|
      t.references :school, null: false, foreign_key: true
      t.references :grade, foreign_key: true
      t.references :subject, foreign_key: true
      t.string :name, null: false
      t.string :code
      t.string :domain
      t.text   :description
      t.timestamps
      t.index [ :school_id, :code ]
    end

    create_table :competency_scores do |t|
      t.references :school, null: false, foreign_key: true
      t.references :competency, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :assessed_by, foreign_key: { to_table: :staffs }
      t.string :term, null: false
      t.string :level, null: false                        # emerging developing proficient exemplary
      t.text   :remarks
      t.date   :assessed_on
      t.timestamps
      t.index [ :competency_id, :student_id, :term ], unique: true, name: "idx_competency_score_unique"
    end

    # --- Live classes
    create_table :live_classes do |t|
      t.references :school, null: false, foreign_key: true
      t.references :section, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :staff, foreign_key: true
      t.string   :title, null: false
      t.datetime :starts_at, null: false
      t.integer  :duration_minutes, default: 45, null: false
      t.string   :platform, default: "meet", null: false
      t.string   :join_url
      t.string   :status, default: "scheduled", null: false
      t.timestamps
      t.index [ :school_id, :starts_at ]
    end

    # --- Study centre
    create_table :study_materials do |t|
      t.references :school, null: false, foreign_key: true
      t.references :grade, foreign_key: true
      t.references :subject, foreign_key: true
      t.references :staff, foreign_key: true
      t.string  :title, null: false
      t.string  :kind, default: "notes", null: false      # notes video worksheet link
      t.string  :url
      t.text    :description
      t.boolean :published, default: true, null: false
      t.integer :downloads, default: 0, null: false
      t.timestamps
      t.index [ :school_id, :kind ]
    end

    # --- Digital evaluation
    create_table :evaluations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :exam_schedule, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :evaluator, foreign_key: { to_table: :staffs }
      t.decimal  :marks, precision: 6, scale: 2
      t.string   :status, default: "pending", null: false # pending in_review completed
      t.text     :remarks
      t.datetime :evaluated_at
      t.timestamps
      t.index [ :exam_schedule_id, :student_id ], unique: true, name: "idx_evaluation_unique"
    end
  end
end
