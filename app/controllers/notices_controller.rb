class NoticesController < ApplicationController
  before_action -> { authorize!("notices.read") },  only: [ :index, :show ]
  before_action -> { authorize!("notices.write") }, except: [ :index, :show ]
  before_action :set_notice, only: [ :show, :edit, :update, :destroy ]

  def index = @notices = paginate(Notice.order(published_at: :desc, created_at: :desc))
  def show; end
  def new  = @notice = Notice.new(published_at: Time.current, audience: "all")
  def edit; end

  def create
    @notice = Notice.new(notice_params.merge(created_by: current_user))
    @notice.save ? redirect_to(@notice, notice: "Posted.") : render(:new, status: :unprocessable_entity)
  end

  def update
    @notice.update(notice_params) ? redirect_to(@notice, notice: "Updated.") : render(:edit, status: :unprocessable_entity)
  end

  def destroy
    @notice.destroy
    redirect_to notices_path, notice: "Deleted."
  end

  private

  def set_notice = @notice = Notice.find(params[:id])
  def notice_params = params.expect(notice: [ :title, :body, :audience, :section_id, :published_at, :expires_on ])
end
