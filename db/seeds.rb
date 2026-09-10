# Idempotent demo data. bin/rails db:seed
ActiveRecord::Base.transaction do
  Current.school = nil
  SEED_PASSWORD = AppConfig.dig(:seed, :password)

  super_admin = User.find_or_initialize_by(email_address: AppConfig.dig(:seed, :super_admin_email), school_id: nil)
  super_admin.update!(name: "Platform Admin", kind: "super_admin", password: SEED_PASSWORD)

  # Optional modules that have a controller today. Grow this as modules land —
  # it keeps the sidebar from advertising screens that don't exist yet.
  BUILT_MODULES = %w[homework timetable library transport hostel inventory assets
                     front_office gate_pass health cctv workers biometrics
                     admissions certificates id_cards payroll accounts].freeze

  ROLE_PERMISSIONS = {
    "Principal"  => %w[*],
    "Admin"      => SchoolModule.all.map { "#{it.key}.*" },
    "Teacher"    => %w[students.read attendance.* homework.* exams.read exams.update timetable.read notices.read academics.read],
    "Accountant" => %w[fees.* accounts.* students.read reports.read notices.read],
    "Parent"     => %w[students.read fees.read attendance.read homework.read exams.read notices.read timetable.read chat.*],
    "Student"    => %w[attendance.read homework.* exams.read notices.read timetable.read study_center.read]
  }.freeze

  [
    { name: "Springfield Public School", code: "SPS", subdomain: "springfield", city: "Pune" },
    { name: "Riverdale International",   code: "RIV", subdomain: "riverdale",   city: "Nashik" }
  ].each_with_index do |attrs, idx|
    school = School.find_or_initialize_by(code: attrs[:code])
    school.update!(attrs.merge(
      email: "office@#{attrs[:subdomain]}.test", phone: "+91 98#{idx}0011223",
      subscription_ends_on: 1.year.from_now.to_date,
      enabled_modules: BUILT_MODULES
    ))
    Current.school = school
    Current.academic_year = nil

    year = AcademicYear.find_or_initialize_by(name: "2026-27")
    year.update!(starts_on: Date.new(2026, 4, 1), ends_on: Date.new(2027, 3, 31), current: true)
    Current.academic_year = year

    roles = ROLE_PERMISSIONS.to_h do |name, perms|
      role = Role.find_or_initialize_by(name: name, school_id: school.id)
      role.update!(permissions: perms, system: true)
      [ name, role ]
    end

    principal = User.find_or_initialize_by(email_address: "principal@#{attrs[:subdomain]}.test", school_id: school.id)
    principal.update!(name: "Dr. #{%w[Anita Rajesh][idx]} Sharma", kind: "admin", password: SEED_PASSWORD)
    principal.roles = [ roles["Principal"] ]

    departments = %w[Science Mathematics Languages Commerce Administration].map { Department.find_or_create_by!(name: it) }
    fee_heads = %w[Tuition Transport Library Examination Sports].map { FeeHead.find_or_create_by!(name: it) }

    subjects = [ "English", "Mathematics", "Science", "Social Studies", "Hindi", "Computer Science" ]
      .map { |name| Subject.find_or_create_by!(name:) { |s| s.code = name[0, 3].upcase } }

    teachers = 12.times.map do |n|
      user = User.find_or_initialize_by(email_address: "teacher#{n + 1}@#{attrs[:subdomain]}.test", school_id: school.id)
      user.update!(name: "#{%w[Priya Amit Sneha Vikas Meera Rohit Kavya Arjun Divya Nikhil Pooja Sanjay][n]} #{%w[Patil Joshi Rao Nair Desai Iyer Kulkarni Menon Shah Gupta Reddy Verma][n]}",
                   kind: "teacher", password: SEED_PASSWORD, phone: "+9198#{format("%08d", n)}")
      user.roles = [ roles["Teacher"] ]
      staff = Staff.find_or_initialize_by(employee_no: "EMP#{format("%03d", n + 1)}")
      staff.update!(user:, first_name: user.name.split.first, last_name: user.name.split.last,
                    department: departments.sample, designation: "Teacher", joining_date: rand(1..8).years.ago.to_date,
                    date_of_birth: rand(28..52).years.ago.to_date, gender: n.even? ? "female" : "male",
                    phone: user.phone, email: user.email_address, qualification: %w[M.Sc B.Ed M.A Ph.D].sample,
                    basic_salary: rand(28_000..65_000), biometric_id: "B#{1000 + n}")
      staff
    end

    grades = (1..8).map { |lvl| Grade.find_or_create_by!(name: "Class #{lvl}") { |g| g.level = lvl } }

    grades.each_with_index do |grade, gi|
      %w[A B].each do |sec_name|
        section = Section.find_or_initialize_by(grade:, name: sec_name)
        section.update!(capacity: 40, room: "R#{grade.level}#{sec_name}", class_teacher: teachers[(gi * 2 + (sec_name == "A" ? 0 : 1)) % teachers.size])
        subjects.each { |sub| SubjectAssignment.find_or_create_by!(section:, subject: sub) { it.staff = teachers.sample } }

        # timetable: 6 periods a day, Mon–Fri
        (1..5).each do |wd|
          subjects.take(6).each_with_index do |sub, p|
            slot = TimetableSlot.find_or_initialize_by(section:, weekday: wd, starts_at: "#{8 + p}:00")
            slot.assign_attributes(academic_year: year, subject: sub, ends_at: "#{8 + p}:45", room: section.room,
                                   staff: SubjectAssignment.find_by(section:, subject: sub)&.staff)
            slot.save(validate: false)
          end
        end
      end

      fee_heads.each do |head|
        fs = FeeStructure.find_or_initialize_by(academic_year: year, grade:, fee_head: head)
        fs.update!(amount: { "Tuition" => 1200 + grade.level * 150, "Transport" => 800, "Library" => 150,
                             "Examination" => 400, "Sports" => 200 }[head.name],
                   frequency: %w[Examination Sports].include?(head.name) ? "annual" : "monthly")
      end
    end

    first_names = %w[Aarav Vivaan Aditya Sai Ananya Diya Isha Kabir Myra Reyansh Anika Vihaan Saanvi Aryan Kiara Advik Navya Ishaan Riya Arnav]
    last_names  = %w[Sharma Patel Reddy Nair Iyer Singh Mehta Bose Kapoor Chauhan]

    120.times do |n|
      adm = "#{attrs[:code]}#{2026}#{format("%04d", n + 1)}"
      student = Student.find_or_initialize_by(admission_no: adm)
      student.update!(first_name: first_names[n % first_names.size], last_name: last_names[n % last_names.size],
                      date_of_birth: (rand(6..15).years.ago - rand(365).days).to_date,
                      gender: n.even? ? "male" : "female", blood_group: %w[A+ B+ O+ AB+].sample,
                      admission_date: rand(1..4).years.ago.to_date, status: "active",
                      house: %w[Red Blue Green Yellow].sample, biometric_id: "S#{5000 + n}",
                      address: "#{rand(1..99)} MG Road, #{attrs[:city]}")

      guardian = Guardian.find_or_initialize_by(name: "#{last_names[n % last_names.size]} Parent #{n + 1}")
      guardian.update!(relation: n.even? ? "Father" : "Mother", phone: "+9199#{format("%08d", n)}",
                       email: "parent#{n + 1}@#{attrs[:subdomain]}.test", occupation: %w[Engineer Teacher Doctor Business].sample)
      Guardianship.find_or_create_by!(guardian:, student:) { it.primary_contact = true }

      if n < 20 # give the first 20 parents a real login
        pu = User.find_or_initialize_by(email_address: guardian.email, school_id: school.id)
        pu.update!(name: guardian.name, kind: "parent", password: SEED_PASSWORD, phone: guardian.phone)
        pu.roles = [ roles["Parent"] ]
        guardian.update!(user: pu)
      end

      section = Section.joins(:grade).order("grades.level", :name).offset(n % 16).first
      Enrollment.find_or_create_by!(academic_year: year, student:) { it.section = section; it.roll_no = (n / 16 + 1).to_s }
    end

    students = Student.active.to_a

    # 20 school days of attendance
    dates = (0..29).map { Date.current - it }.reject { it.saturday? || it.sunday? }.first(20)
    dates.each do |date|
      rows = students.map do |st|
        { school_id: school.id, academic_year_id: year.id, attendable_type: "Student", attendable_id: st.id,
          section_id: st.section&.id, on_date: date, source: "biometric",
          status: (r = rand(100)) < 88 ? "present" : r < 94 ? "absent" : r < 98 ? "late" : "leave",
          created_at: Time.current, updated_at: Time.current }
      end
      Attendance.insert_all(rows, unique_by: :idx_attendance_unique)
    end

    # invoices for the last 3 months
    3.downto(0) do |back|
      period_date = back.months.ago.to_date
      students.each do |st|
        next unless st.section
        structures = FeeStructure.where(academic_year: year, grade_id: st.section.grade_id, frequency: "monthly")
        invoice = FeeInvoice.find_or_initialize_by(student: st, period: period_date.strftime("%Y-%m"))
        next if invoice.persisted?
        invoice.assign_attributes(academic_year: year, issue_date: period_date.beginning_of_month,
                                  due_date: period_date.beginning_of_month + 9)
        invoice.fee_invoice_items = structures.map { FeeInvoiceItem.new(fee_head: it.fee_head, description: "#{it.fee_head.name} — #{period_date.strftime("%b %Y")}", amount: it.amount) }
        invoice.save!
        invoice.refresh_totals!
        if rand(100) < 78
          FeePayment.create!(fee_invoice: invoice, amount: invoice.balance, method: %w[cash upi online card].sample,
                             received_by: principal, paid_at: [ invoice.due_date - rand(0..8).days, Time.current ].min,
                             reference: SecureRandom.alphanumeric(8).upcase)
        end
      end
    end

    exam = Exam.find_or_initialize_by(academic_year: year, name: "Mid-Term 2026")
    exam.update!(exam_type: "term", starts_on: 3.weeks.ago.to_date, ends_on: 2.weeks.ago.to_date, published: true)
    Section.includes(:grade).find_each do |section|
      subjects.take(4).each_with_index do |sub, i|
        sch = ExamSchedule.find_or_initialize_by(exam:, section:, subject: sub)
        sch.update!(on_date: exam.starts_on + i, starts_at: "10:00", ends_at: "12:00", max_marks: 100, pass_marks: 33, room: section.room)
        rows = section.students.map { { exam_schedule_id: sch.id, student_id: it.id, marks: rand(20..99), absent: false, created_at: Time.current, updated_at: Time.current } }
        ExamResult.insert_all(rows, unique_by: :idx_result_unique) if rows.any?
      end
    end

    [ [ "Annual Sports Day", "Sports day on the 24th. Students report in house colours by 8am." ],
     [ "Fee reminder", "Tuition fees for this month are due on the 10th. Pay via the parent app to avoid a late fine." ],
     [ "PTM Schedule", "Parent-teacher meetings this Saturday, 9am–1pm. Slots open in the app." ] ].each do |title, body|
      n = Notice.find_or_initialize_by(title:)
      n.update!(body:, audience: "all", published_at: rand(1..10).days.ago, created_by: principal)
    end


    # ---- Operations modules -------------------------------------------------
    titles = [ [ "The Jungle Book", "Rudyard Kipling" ], [ "A Brief History of Time", "Stephen Hawking" ],
              [ "Wings of Fire", "A P J Abdul Kalam" ], [ "Malgudi Days", "R K Narayan" ],
              [ "The Alchemist", "Paulo Coelho" ], [ "Discovery of India", "Jawaharlal Nehru" ],
              [ "Panchatantra", "Vishnu Sharma" ], [ "Train to Pakistan", "Khushwant Singh" ],
              [ "The Guide", "R K Narayan" ], [ "Gitanjali", "Rabindranath Tagore" ] ]
    books = titles.flat_map { |title, author|
      %w[Fiction Science History Reference].first(2).map do |category|
        book = Book.find_or_initialize_by(title: "#{title} (#{category})")
        copies = rand(2..6)
        book.update!(author:, category:, isbn: "978#{rand(1_000_000_000..9_999_999_999)}",
                     publisher: %w[Penguin Rupa Scholastic Oxford].sample, rack: "R#{rand(1..12)}",
                     copies:, available: copies, price: rand(120..680))
        book
      end
    }

    students_for_modules = Student.active.order(:id).to_a
    if BookIssue.count.zero?
      20.times do |n|
        issued = rand(1..40).days.ago.to_date
        BookIssue.create!(book: books.sample, student: students_for_modules[n], issued_on: issued,
                          due_on: issued + 14, returned_on: n.even? ? issued + rand(3..13) : nil,
                          fine: n.even? ? 0 : rand(0..40))
      end
    end

    lat, lng = idx.zero? ? [ 18.5204, 73.8567 ] : [ 19.9975, 73.7898 ]
    vehicles = 4.times.map do |n|
      v = Vehicle.find_or_initialize_by(registration_no: "MH#{12 + idx}AB#{1000 + n}")
      v.update!(model: [ "Tata Starbus", "Force Traveller", "Ashok Leyland Lynx", "Eicher Skyline" ][n],
                capacity: [ 40, 26, 45, 32 ][n], driver: teachers[n], gps_device_id: "GPS#{2000 + n}",
                insurance_expires_on: rand(30..300).days.from_now.to_date,
                fitness_expires_on: rand(60..400).days.from_now.to_date)
      v
    end

    [ "North Loop", "Station Road", "Old City", "Lake Side" ].each_with_index do |name, n|
      route = TransportRoute.find_or_initialize_by(name:)
      route.update!(vehicle: vehicles[n], start_point: "Campus Gate",
                    end_point: [ "Aundh", "Railway Station", "Fort", "Lakeview" ][n], fare: [ 900, 750, 800, 1000 ][n])
      5.times do |i|
        stop = RouteStop.find_or_initialize_by(transport_route: route, name: "#{route.end_point} Stop #{i + 1}")
        stop.update!(pickup_at: "#{7 + (i / 3)}:#{format("%02d", (i * 12) % 60)}",
                     drop_at: "#{15 + (i / 3)}:#{format("%02d", (i * 12) % 60)}",
                     latitude: lat + (i * 0.006) - 0.012, longitude: lng + (i * 0.007) - 0.014, position: i)
      end
    end

    TransportRoute.find_each do |route|
      route.route_stops.first(2).each_with_index do |stop, i|
        students_for_modules.each_slice(30).first.each_slice(8).to_a[i].to_a.each do |student|
          TransportAssignment.find_or_create_by!(student:, transport_route: route) { it.route_stop = stop }
        end
      end
    end

    if VehicleLocation.count.zero?
      vehicles.first(2).each_with_index do |vehicle, vi|
        20.times do |i|
          vehicle.vehicle_locations.create!(latitude: lat + vi * 0.01 + i * 0.0008,
                                            longitude: lng + vi * 0.01 + i * 0.0011,
                                            speed: rand(12..46), heading: rand(0..359),
                                            recorded_at: (20 - i).minutes.ago)
        end
      end
    end

    boys = Hostel.find_or_initialize_by(name: "Tagore House")
    boys.update!(kind: "boys", warden: teachers[5], capacity: 60, address: "East campus")
    girls = Hostel.find_or_initialize_by(name: "Nightingale House")
    girls.update!(kind: "girls", warden: teachers[6], capacity: 48, address: "West campus")
    [ boys, girls ].each do |hostel|
      (1..6).each do |n|
        room = HostelRoom.find_or_initialize_by(hostel:, number: "#{hostel.kind == "boys" ? "B" : "G"}#{100 + n}")
        room.update!(kind: n <= 2 ? "single" : "shared", capacity: n <= 2 ? 1 : 3, rent: n <= 2 ? 4500 : 2800)
      end
    end
    if HostelAllocation.count.zero?
      HostelRoom.find_each.with_index do |room, i|
        room.capacity.times do |b|
          student = students_for_modules[(i * 3 + b) % students_for_modules.size]
          next if HostelAllocation.exists?(student:)
          HostelAllocation.create!(hostel_room: room, student:, bed_no: "#{b + 1}", from_on: 4.months.ago.to_date)
        end
      end
    end

    [ [ "Chalk box", "Stationery", "box", 120, 30, 45 ], [ "A4 paper ream", "Stationery", "ream", 60, 20, 260 ],
     [ "Whiteboard marker", "Stationery", "pcs", 240, 60, 30 ], [ "Floor cleaner", "Housekeeping", "litre", 40, 15, 110 ],
     [ "Hand wash", "Housekeeping", "litre", 25, 10, 180 ], [ "Tube light", "Electrical", "pcs", 80, 25, 220 ],
     [ "Ceiling fan", "Electrical", "pcs", 12, 5, 1650 ], [ "Football", "Sports", "pcs", 18, 6, 900 ],
     [ "Cricket bat", "Sports", "pcs", 9, 4, 1400 ], [ "First-aid kit", "Medical", "pcs", 14, 5, 750 ],
     [ "Lab beaker", "Laboratory", "pcs", 95, 30, 140 ], [ "Microscope slide", "Laboratory", "box", 22, 10, 320 ]
    ].each do |name, category, unit, quantity, reorder, cost|
      item = InventoryItem.find_or_initialize_by(name:)
      item.update!(category:, unit:, quantity:, reorder_level: reorder, unit_cost: cost, store: "Main store")
    end
    if StockMovement.count.zero?
      InventoryItem.find_each do |item|
        StockMovement.create!(inventory_item: item, direction: "in", quantity: rand(5..25),
                              reason: "Purchase order", on_date: rand(5..60).days.ago.to_date, recorded_by: principal)
        StockMovement.create!(inventory_item: item, direction: "out", quantity: rand(1..5),
                              reason: "Issued to department", on_date: rand(1..20).days.ago.to_date, recorded_by: principal)
      end
    end

    [ [ "Projector", "Electronics", 42_000 ], [ "Desktop PC", "Electronics", 38_000 ], [ "Laser printer", "Electronics", 16_500 ],
     [ "Science lab bench", "Furniture", 22_000 ], [ "Staff room sofa", "Furniture", 18_000 ], [ "Library shelf", "Furniture", 9_500 ],
     [ "Water purifier", "Utility", 24_000 ], [ "Generator 15kVA", "Utility", 185_000 ], [ "Smart board", "Electronics", 96_000 ],
     [ "Sports trampoline", "Sports", 31_000 ] ].each_with_index do |(name, category, cost), n|
      asset = Asset.find_or_initialize_by(code: "AST-#{format("%03d", n + 1)}")
      asset.update!(name:, category:, cost:, purchased_on: rand(1..5).years.ago.to_date,
                    location: [ "Block A", "Block B", "Lab", "Library", "Ground" ].sample,
                    assigned_to: teachers.sample, condition: %w[good good good fair].sample,
                    status: %w[in_use in_use in_store repair].sample,
                    warranty_expires_on: rand(-200..500).days.from_now.to_date)
    end

    if Visitor.count.zero?
      12.times do |n|
        in_at = rand(1..14).days.ago.change(hour: rand(9..16), min: [ 0, 15, 30, 45 ].sample)
        Visitor.create!(name: "#{%w[Suresh Anita Farid Meena Joseph Kiran].sample} #{%w[Kale Shah Khan Pillai D'Souza].sample}",
                        phone: "+9198#{format("%08d", rand(1e8))}",
                        purpose: [ "Admission enquiry", "Meet class teacher", "Fee payment", "Vendor delivery", "Document collection" ].sample,
                        meeting: teachers.sample, pass_no: "V#{1000 + n}", party_size: rand(1..3),
                        in_at:, out_at: n.even? ? in_at + rand(20..90).minutes : nil)
      end
      8.times do
        PhoneLog.create!(caller_name: "#{%w[Parent Vendor Board Inspector].sample} call",
                         phone: "+9197#{format("%08d", rand(1e8))}", direction: %w[incoming outgoing].sample,
                         purpose: [ "Fee query", "Leave intimation", "Supply order", "Circular follow-up" ].sample,
                         called_at: rand(1..10).days.ago, notes: "Handled at front desk.")
      end
      6.times do |n|
        PostalRecord.create!(direction: n.even? ? "received" : "dispatched", reference_no: "PST-#{200 + n}",
                             from_name: n.even? ? "Education Board" : school.name,
                             to_name: n.even? ? school.name : "District Office",
                             on_date: rand(1..25).days.ago.to_date, notes: "Logged at reception.")
      end
    end

    if GatePass.count.zero?
      6.times do |n|
        out_at = rand(1..12).days.ago.change(hour: rand(10..15))
        GatePass.create!(student: students_for_modules[n * 3], reason: [ "Doctor appointment", "Family function", "Unwell", "Sports trial" ].sample,
                         out_at:, in_at: n.even? ? out_at + rand(1..4).hours : nil,
                         status: n.even? ? "returned" : "approved", approved_by: principal)
      end
    end

    if HealthRecord.count.zero?
      students_for_modules.first(24).each do |student|
        HealthRecord.create!(student:, checked_on: rand(5..90).days.ago.to_date,
                             height_cm: rand(110..175) + rand.round(1), weight_kg: rand(22..68) + rand.round(1),
                             blood_pressure: "#{rand(100..125)}/#{rand(65..85)}", pulse: rand(68..96),
                             vision: %w[6/6 6/9 6/12].sample, allergies: [ "None", "Dust", "Peanuts" ].sample,
                             notes: "Routine annual check-up.")
      end
    end

    [ "Main Gate", "Reception", "Corridor A", "Playground", "Library", "Bus Bay" ].each do |place|
      cam = Camera.find_or_initialize_by(name: "#{place} Cam")
      cam.update!(location: place, stream_url: "rtsp://cctv.local/#{place.parameterize}", active: true)
    end

    [ [ "Ramesh Pawar", "Gardener", "morning" ], [ "Sunita Jadhav", "Housekeeping", "morning" ],
     [ "Iqbal Shaikh", "Security", "night" ], [ "Laxmi Bhosale", "Housekeeping", "afternoon" ],
     [ "Ganesh More", "Electrician", "full day" ], [ "Vijay Kamble", "Security", "morning" ],
     [ "Shobha Gaikwad", "Canteen", "full day" ], [ "Anil Thorat", "Driver helper", "morning" ]
    ].each do |name, role, shift|
      worker = CampusWorker.find_or_initialize_by(name:)
      worker.update!(role:, shift:, phone: "+9196#{format("%08d", rand(1e8))}",
                     daily_wage: rand(450..900), joined_on: rand(1..6).years.ago.to_date, status: "active")
    end

    [ "Main Gate ADMS", "Staff Room ADMS" ].each_with_index do |name, n|
      dev = BiometricDevice.find_or_initialize_by(serial_number: "ZK#{idx}#{n}00#{rand(100..999)}")
      dev.update!(name:, ip_address: "192.168.#{idx + 1}.#{20 + n}", location: name.sub(" ADMS", ""),
                  last_seen_at: rand(1..90).minutes.ago, active: true)
    end


    # ---- People & finance modules ------------------------------------------
    if AdmissionEnquiry.count.zero?
      18.times do |n|
        enquired = rand(1..45).days.ago.to_date
        AdmissionEnquiry.create!(
          student_name: "#{first_names.sample} #{last_names.sample}",
          guardian_name: "#{last_names.sample} #{%w[Sr. Ji].sample}",
          phone: "+9195#{format("%08d", rand(1e8))}", email: "enq#{n}@example.com",
          grade: grades.sample, source: [ "Walk-in", "Website", "Referral", "Phone", "Social media" ].sample,
          status: AdmissionEnquiry::STATUSES.sample, enquired_on: enquired,
          follow_up_on: enquired + rand(3..20), assigned_to: principal,
          notes: "Enquiry logged at the front desk.")
      end
    end

    [ [ "Bonafide Certificate", "bonafide",
      "This is to certify that {{student_name}} (Admission No {{admission_no}}) is a bonafide student of {{school}}, studying in {{class}}. Issued on {{date}}." ],
     [ "Transfer Certificate", "transfer",
      "{{student_name}}, Admission No {{admission_no}}, of {{class}} is hereby granted a transfer certificate from {{school}} on {{date}}." ],
     [ "Character Certificate", "character",
      "{{student_name}} of {{class}} has borne a good moral character during the period of study at {{school}}. Issued {{date}}." ]
    ].each do |name, kind, body|
      tpl = CertificateTemplate.find_or_initialize_by(name:)
      tpl.update!(kind:, body:)
    end
    if IssuedCertificate.count.zero?
      CertificateTemplate.find_each do |tpl|
        students_for_modules.sample(4).each do |student|
          IssuedCertificate.create!(certificate_template: tpl, student:, issued_by: principal,
                                    issued_on: rand(1..120).days.ago.to_date, remarks: "Issued on request.")
        end
      end
    end

    [ [ "Student Card — Portrait", "student", "portrait" ], [ "Staff Card — Portrait", "staff", "portrait" ],
     [ "Student Card — Landscape", "student", "landscape" ] ].each do |name, audience, orientation|
      tpl = IdCardTemplate.find_or_initialize_by(name:)
      tpl.update!(audience:, orientation:, background_color: school.primary_color,
                  fields: %w[photo name admission_no class blood_group phone],
                  active: orientation == "portrait")
    end

    if Payslip.count.zero?
      3.downto(1) do |back|
        period = (Date.current << back).strftime("%Y-%m")
        Staff.active.find_each do |member|
          basic = member.basic_salary || 30_000
          Payslip.create!(staff: member, period:, basic:,
                          allowances: (basic * 0.18).round, deductions: (basic * 0.09).round,
                          days_present: rand(22..26), status: "paid",
                          paid_on: Date.parse("#{period}-28"))
        end
      end
    end

    if LedgerEntry.count.zero?
      expenses = [ [ "Electricity bill", "Utilities" ], [ "Water charges", "Utilities" ], [ "Housekeeping supplies", "Maintenance" ],
                  [ "Bus diesel", "Transport" ], [ "Lab consumables", "Academics" ], [ "Printer toner", "Office" ],
                  [ "Sports equipment", "Sports" ], [ "Staff training", "HR" ], [ "Building repairs", "Maintenance" ] ]
      incomes  = [ [ "Fee collection deposit", "Fees" ], [ "Hostel rent", "Hostel" ], [ "Transport fare", "Transport" ],
                  [ "Donation", "Grants" ], [ "Book sales", "Library" ] ]
      40.times do
        income = rand(3).zero?
        description, category = (income ? incomes : expenses).sample
        LedgerEntry.create!(direction: income ? "income" : "expense", description:, category:,
                            amount: income ? rand(20_000..180_000) : rand(1_500..48_000),
                            on_date: rand(1..90).days.ago.to_date,
                            payment_mode: %w[cash upi bank cheque].sample,
                            reference: "REF#{rand(10_000..99_999)}", recorded_by: principal)
      end
    end

    puts "#{school.name}: #{Student.count} students, #{Staff.count} staff, #{FeeInvoice.count} invoices, #{Attendance.count} attendance rows"
  end
  Current.school = nil
end
