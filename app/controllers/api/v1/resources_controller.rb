module Api
  module V1
    # JSON CRUD for every Manageable model — driven by the same declaration the
    # web UI renders, so a new module gets an API for free.
    class ResourcesController < BaseController
      before_action :set_model
      before_action :authorize_read,  only: [:index, :show]
      before_action :authorize_write, except: [:index, :show]

      def index
        scope = @model.all
        scope = search(scope)
        resource_config[:fields].select(&:belongs_to?).each do |f|
          scope = scope.where(f.key => params[f.key]) if params[f.key].present?
        end
        result = paginate(scope.order(resource_config[:order]))
        render json: result.merge(data: result[:data].map { serialize(it) })
      end

      def show   = render(json: serialize(@model.find(params[:id])))
      def create
        record = @model.new(record_params)
        record.save ? render(json: serialize(record), status: :created) : render_invalid(record)
      end

      def update
        record = @model.find(params[:id])
        record.update(record_params) ? render(json: serialize(record)) : render_invalid(record)
      end

      def destroy
        @model.find(params[:id]).destroy
        head :no_content
      end

      private

      def resource_config = @model.manage_config

      def set_model
        @model = params[:resource].to_s.classify.safe_constantize
        raise ActiveRecord::RecordNotFound unless @model.respond_to?(:manageable?) && @model.manageable?
      end

      def authorize_read  = authorize!("#{resource_config[:module_key]}.read")
      def authorize_write = authorize!("#{resource_config[:module_key]}.write")
      def record_params   = params.expect(@model.model_name.param_key.to_sym => @model.permitted_params)
      def render_invalid(record) = render(json: { error: "invalid", details: record.errors.to_hash }, status: :unprocessable_entity)

      def search(scope)
        return scope if params[:q].blank? || resource_config[:search].empty?
        clause = resource_config[:search].map { "#{@model.table_name}.#{it} ILIKE :q" }.join(" OR ")
        scope.where(clause, q: "%#{params[:q]}%")
      end

      # Raw attributes plus resolved labels for belongs_to, which is what a list
      # screen needs without an extra round trip.
      def serialize(record)
        labels = resource_config[:fields].select(&:belongs_to?).to_h do |f|
          [f.name, record.public_send(f.name).then { it && (it.try(:name) || it.try(:title) || it.try(:full_name)) }]
        end
        record.as_json.merge("labels" => labels)
      end
    end
  end
end
