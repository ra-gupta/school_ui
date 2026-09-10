class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.references :school, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
      t.index [:school_id, :name], unique: true
    end

    create_table :staffs do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :department, foreign_key: true
      t.string  :employee_no, null: false
      t.string  :first_name, null: false
      t.string  :last_name
      t.string  :designation
      t.date    :joining_date
      t.date    :date_of_birth
      t.string  :gender
      t.string  :phone
      t.string  :email
      t.string  :qualification
      t.text    :address
      t.decimal :basic_salary, precision: 12, scale: 2
      t.string  :biometric_id
      t.string  :status, default: "active", null: false
      t.jsonb   :custom_fields, default: {}, null: false
      t.timestamps
      t.index [:school_id, :employee_no], unique: true
      t.index [:school_id, :biometric_id]
    end

    create_table :grades do |t|
      t.references :school, null: false, foreign_key: true
      t.string  :name, null: false
      t.integer :level, null: false, default: 0
      t.timestamps
      t.index [:school_id, :name], unique: true
    end

    create_table :sections do |t|
      t.references :school, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true
      t.references :class_teacher, foreign_key: { to_table: :staffs }
      t.string  :name, null: false
      t.integer :capacity, default: 40, null: false
      t.string  :room
      t.timestamps
      t.index [:grade_id, :name], unique: true
    end

    create_table :subjects do |t|
      t.references :school, null: false, foreign_key: true
      t.references :grade, foreign_key: true
      t.string  :name, null: false
      t.string  :code
      t.string  :subject_type, default: "theory", null: false
      t.timestamps
      t.index [:school_id, :code]
    end

    create_table :subject_assignments do |t|
      t.references :section, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :staff, foreign_key: true
      t.timestamps
      t.index [:section_id, :subject_id], unique: true
    end

    create_table :students do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string  :admission_no, null: false
      t.string  :first_name, null: false
      t.string  :last_name
      t.date    :date_of_birth
      t.string  :gender
      t.string  :blood_group
      t.string  :phone
      t.string  :email
      t.text    :address
      t.date    :admission_date
      t.string  :status, default: "active", null: false # active alumni left suspended
      t.string  :house
      t.string  :religion
      t.string  :category
      t.string  :national_id
      t.string  :biometric_id
      t.string  :previous_school
      t.text    :notes
      t.jsonb   :custom_fields, default: {}, null: false
      t.timestamps
      t.index [:school_id, :admission_no], unique: true
      t.index [:school_id, :biometric_id]
    end

    create_table :guardians do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.string :relation
      t.string :phone
      t.string :email
      t.string :occupation
      t.text   :address
      t.timestamps
    end

    create_table :guardianships do |t|
      t.references :guardian, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.boolean :primary_contact, default: false, null: false
      t.timestamps
      t.index [:guardian_id, :student_id], unique: true
    end

    create_table :enrollments do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_year, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.string  :roll_no
      t.string  :status, default: "active", null: false
      t.timestamps
      t.index [:academic_year_id, :student_id], unique: true
    end
  end
end
