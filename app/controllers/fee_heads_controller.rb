class FeeHeadsController < ApplicationController
  before_action -> { authorize!("fees.write") }, except: :index
  before_action -> { authorize!("fees.read") },  only: :index

  def index = @fee_heads = FeeHead.order(:name)

  def create
    FeeHead.create(name: params.require(:fee_head)[:name])
    redirect_to fee_heads_path
  end

  def destroy
    FeeHead.find(params[:id]).destroy
    redirect_to fee_heads_path, notice: "Removed."
  end
end
