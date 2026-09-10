module Api
  module V1
    class TimetableController < BaseController
      def index
        authorize!("timetable.read")
        scope = TimetableSlot.includes(:subject, :staff, :section)
        scope = scope.where(section_id: params[:section_id]) if params[:section_id].present?
        scope = scope.where(staff_id: params[:staff_id]) if params[:staff_id].present?
        scope = scope.where(weekday: params[:weekday]) if params[:weekday].present?
        render json: scope.order(:weekday, :starts_at).map { |s|
          { id: s.id, weekday: s.weekday, starts_at: s.starts_at.strftime("%H:%M"),
            ends_at: s.ends_at.strftime("%H:%M"), room: s.room,
            section: s.section.full_name, subject: s.subject&.name, teacher: s.staff&.name }
        }
      end
    end
  end
end
