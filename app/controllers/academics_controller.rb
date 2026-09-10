class AcademicsController < ApplicationController
  before_action -> { authorize!("academics.read") }

  def index
    @grades   = Grade.ordered.includes(sections: :class_teacher)
    @subjects = Subject.includes(:grade).order(:name)
    @grade    = Grade.new
    @section  = Section.new
    @subject  = Subject.new
  end
end
