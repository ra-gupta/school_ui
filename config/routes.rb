Rails.application.routes.draw do
  resource  :session
  resources :passwords, param: :token

  root "dashboard#show"

  resources :schools, except: :destroy do
    member     { post :enter }
    collection { delete :leave }
  end

  resources :students do
    resources :fee_invoices, only: :index, module: :students
  end

  scope "/hr" do
    resources :staffs, path: "", as: :staffs
  end

  resource :attendance, only: [ :show, :update ], controller: "attendance"

  scope "/fees" do
    root "fee_invoices#index", as: :fees
    resources :fee_invoices, path: "invoices" do
      resources :fee_payments, only: [ :create, :destroy ], path: "payments"
    end
    resources :fee_structures, path: "structures", except: [ :show ]
    resources :fee_heads, path: "heads", except: [ :show, :new, :edit ]
  end

  resources :exams do
    resources :exam_schedules, only: [ :create, :destroy ], path: "papers"
    get "papers/:exam_schedule_id/marks", to: "exam_results#edit", as: :marks
    patch "papers/:exam_schedule_id/marks", to: "exam_results#update"
  end

  resources :homeworks, path: "homework"
  resources :notices
  resource  :timetable, only: :show

  scope "/academics" do
    root "academics#index", as: :academics
    resources :grades,   except: [ :show ]
    resources :sections, except: [ :show ]
    resources :subjects, except: [ :show ]
  end

  # ---- Modules on the generic resource controller -------------------------
  scope "/library" do
    root "books#index", as: :library
    resources :books, path: "books"
    resources :book_issues, path: "issues"
  end

  scope "/transport" do
    root "transport_routes#index", as: :transport
    resources :transport_routes, path: "routes"
    resources :route_stops, path: "stops"
    resources :vehicles, path: "vehicles"
    resources :transport_assignments, path: "riders"
    get "live", to: "vehicle_tracking#show", as: :transport_live
  end

  scope "/hostel" do
    root "hostels#index", as: :hostel
    resources :hostels, path: "hostels"
    resources :hostel_rooms, path: "rooms"
    resources :hostel_allocations, path: "allocations"
  end

  scope "/inventory" do
    root "inventory_items#index", as: :inventory
    resources :inventory_items, path: "items"
    resources :stock_movements, path: "movements"
  end

  scope "/front-office", as: :front_office do
    root "visitors#index", as: :root
    resources :visitors, path: "visitors"
    resources :phone_logs, path: "calls"
    resources :postal_records, path: "postal"
  end

  resources :assets, path: "asset-register"
  resources :gate_passes, path: "gate-pass"
  resources :health_records, path: "health"
  resources :cameras, path: "cctv"
  resources :campus_workers, path: "workers"
  resources :biometric_devices, path: "biometrics"

  resources :admission_enquiries, path: "admissions"

  scope "/certificates" do
    root "issued_certificates#index", as: :certificates
    resources :issued_certificates, path: "issued"
    resources :certificate_templates, path: "templates"
  end

  resources :id_card_templates, path: "id-cards"
  resources :payslips, path: "payroll"
  resources :ledger_entries, path: "accounts"

  scope "/communications" do
    root "message_logs#index", as: :communications
    resources :message_logs, path: "sent"
    resources :message_templates, path: "templates"
  end

  scope "/ptm" do
    root "ptm_meetings#index", as: :ptm
    resources :ptm_meetings, path: "meetings"
    resources :ptm_slots, path: "slots"
  end

  scope "/surveys" do
    root "surveys#index", as: :surveys_root
    resources :surveys, path: "surveys"
    resources :survey_questions, path: "questions"
  end

  resources :kb_articles, path: "knowledge-base"
  resources :web_pages, path: "website"
  resources :greeting_campaigns, path: "engagement"
  resources :conversations, path: "chat", only: [ :index, :show, :create, :update ]

  scope "/online-exams", as: :online_exams do
    root "online_tests#index", as: :root
    resources :online_tests, path: "tests"
    resources :test_questions, path: "questions"
    resources :test_attempts, path: "attempts"
  end

  scope "/assessment" do
    root "competencies#index", as: :assessment
    resources :competencies, path: "competencies"
    resources :competency_scores, path: "levels"
  end

  resources :lesson_plans, path: "lesson-plans"
  resources :live_classes, path: "live-classes"
  resources :study_materials, path: "study-center"
  resources :evaluations, path: "digital-evaluation"

  # ---- JSON API for the Flutter app ---------------------------------------
  namespace :api do
    namespace :v1 do
      resource  :session, only: [ :create, :destroy ]
      get "me", to: "users#me"
      get "dashboard", to: "dashboard#show"

      get   "attendance",  to: "attendance#index"
      post  "attendance",  to: "attendance#create"
      get   "timetable",   to: "timetable#index"
      get   "fees",        to: "fees#index"
      post  "fees/invoices/:id/payments", to: "fees#pay", as: :fee_payment
      post  "driver/location", to: "driver#location"
      get   "conversations",            to: "chat#index"
      get   "conversations/:id",        to: "chat#show"
      post  "conversations/:id/messages", to: "chat#create"

      # Generic CRUD for every Manageable model, e.g. /api/v1/books
      get    ":resource",     to: "resources#index",   as: :resources
      post   ":resource",     to: "resources#create"
      get    ":resource/:id", to: "resources#show",    as: :resource
      patch  ":resource/:id", to: "resources#update"
      put    ":resource/:id", to: "resources#update"
      delete ":resource/:id", to: "resources#destroy"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
