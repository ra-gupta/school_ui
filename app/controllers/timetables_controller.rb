class TimetablesController < ApplicationController
  before_action -> { authorize!("timetable.read") }

  DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  def show
    @sections = Section.includes(:grade).order("grades.level", :name)
    @section  = @sections.find_by(id: params[:section_id]) || @sections.first
    slots     = @section ? @section.timetable_slots.includes(:subject, :staff) : TimetableSlot.none
    @by_day   = slots.group_by(&:weekday)
    @periods  = slots.map { |s| [s.starts_at, s.ends_at] }.uniq.sort_by(&:first)
  end
end
