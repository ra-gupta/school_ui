module Api
  module V1
    # One call the app can draw a home screen from, shaped by who is asking.
    class DashboardController < BaseController
      def show
        render json: case current_user.kind
                     when "parent", "student" then family_summary
                     when "driver"            then driver_summary
                     else staff_summary
                     end
      end

      private

      def my_students
        @my_students ||= current_user.student ? [current_user.student] : current_user.guardian&.students.to_a
      end

      def family_summary
        {
          role: "family",
          students: my_students.map do |s|
            month = Attendance.where(attendable: s, on_date: Date.current.all_month)
            {
              id: s.id, name: s.name, admission_no: s.admission_no, section: s.section&.full_name,
              attendance_this_month: { present: month.present.count, total: month.count },
              fees_due: s.fees_due.to_f,
              homework_due: Homework.where(section_id: s.section&.id, due_on: Date.current..).count
            }
          end,
          notices: Notice.live.limit(5).as_json(only: [:id, :title, :body, :published_at])
        }
      end

      def staff_summary
        {
          role: "staff",
          students: Student.active.count,
          present_today: Attendance.where(attendable_type: "Student", on_date: Date.current).present.count,
          collected_this_month: FeePayment.where(paid_at: Date.current.all_month, status: "success").sum(:amount).to_f,
          outstanding: FeeInvoice.unpaid.sum("total + fine - discount - paid").to_f,
          my_classes: current_user.staff&.sections&.map { { id: it.id, name: it.full_name } }.to_a,
          notices: Notice.live.limit(5).as_json(only: [:id, :title, :body, :published_at])
        }
      end

      def driver_summary
        vehicle = Vehicle.find_by(driver_id: current_user.staff&.id)
        {
          role: "driver",
          vehicle: vehicle&.as_json(only: [:id, :registration_no, :model]),
          routes: vehicle&.transport_routes&.map { |r|
            { id: r.id, name: r.name, stops: r.route_stops.as_json(only: [:id, :name, :pickup_at, :drop_at, :latitude, :longitude]) }
          }.to_a
        }
      end
    end
  end
end
