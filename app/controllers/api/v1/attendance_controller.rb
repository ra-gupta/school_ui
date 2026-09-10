module Api
  module V1
    class AttendanceController < BaseController
      def index
        authorize!("attendance.read")
        scope = Attendance.where(attendable_type: "Student")
        scope = scope.where(section_id: params[:section_id]) if params[:section_id].present?
        scope = scope.where(attendable_id: params[:student_id]) if params[:student_id].present?
        scope = scope.where(on_date: params[:from].presence || Date.current, on_date: date_range)
        render json: scope.order(:on_date).as_json(only: [ :id, :attendable_id, :section_id, :on_date, :status, :source ])
      end

      # Bulk mark: [{student_id:, status:}, ...] for one section and date.
      def create
        authorize!("attendance.write")
        section = Section.find(params.require(:section_id))
        date    = params[:date].presence&.to_date || Date.current
        rows = params.require(:marks).map do |mark|
          { school_id: Current.school.id, academic_year_id: Current.academic_year&.id,
            attendable_type: "Student", attendable_id: mark[:student_id].to_i, section_id: section.id,
            on_date: date, status: mark[:status], source: "app", marked_by_id: current_user.id,
            created_at: Time.current, updated_at: Time.current }
        end
        if rows.any?
          Attendance.upsert_all(rows, unique_by: :idx_attendance_unique)
          Notifications::AbsenceJob.perform_later(section.id, date)
        end
        render json: { marked: rows.size, date: }, status: :created
      end

      private

      def date_range
        from = params[:from].presence&.to_date || Date.current
        to   = params[:to].presence&.to_date || from
        from..to
      end
    end
  end
end
