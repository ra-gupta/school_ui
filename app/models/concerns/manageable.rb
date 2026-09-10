# Declares how a model is listed, filtered and edited. ResourceController renders
# it as HTML; Api::V1::ResourcesController renders the same declaration as JSON —
# so a module is described once, not twice.
#
#   manage module_key: "library", icon: "📖",
#          columns: [:title, :author, {name: :available, align: :right}],
#          fields:  [:title, :author, {name: :copies, type: :number}],
#          search:  [:title, :author]
module Manageable
  extend ActiveSupport::Concern

  # resource slug => model class. Populated by `manage`, which is why lookups
  # never have to constantize a caller-supplied string.
  REGISTRY = {}

  def self.registry
    # In development and test nothing is loaded until it is referenced, so the
    # registry is only complete once the app has been eager loaded.
    Rails.application.eager_load! unless Rails.application.config.eager_load
    REGISTRY
  end

  def self.[](slug) = registry[slug.to_s]

  Field = Data.define(:name, :type, :options, :label, :align, :required) do
    def belongs_to? = type == :belongs_to
    def key = belongs_to? ? :"#{name}_id" : name
  end

  class_methods do
    attr_reader :manage_config

    def manage(module_key:, columns:, fields:, icon: nil, search: [], order: nil, per_page: AppConfig[:per_page])
      REGISTRY[model_name.plural] = self
      @manage_config = {
        module_key:, icon:, search:, per_page:,
        order: order || { id: :desc },
        columns: columns.map { normalize_field(it) },
        fields:  fields.map { normalize_field(it) }
      }
    end

    def manageable? = @manage_config.present?
    def permitted_params = @manage_config[:fields].map(&:key)

    private

    def normalize_field(spec)
      spec = { name: spec } if spec.is_a?(Symbol)
      name = spec.fetch(:name)
      Field.new(name:, type: spec[:type] || :string, options: spec[:options],
                label: spec[:label] || name.to_s.humanize, align: spec[:align] || :left,
                required: spec.fetch(:required, false))
    end
  end

  # Rendered value for a column, resolving belongs_to to a human name.
  def display(field)
    value = field.belongs_to? ? public_send(field.name) : public_send(field.name)
    case value
    when nil        then nil
    when true       then "Yes"
    when false      then "No"
    when Date, Time then value.to_fs(:long)
    when ActiveRecord::Base then value.try(:name) || value.try(:title) || "##{value.id}"
    else value
    end
  end
end
