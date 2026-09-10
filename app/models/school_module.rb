# Static registry of installable modules, read from config/modules.yml.
SchoolModule = Data.define(:key, :name, :icon, :group, :core, :path) do
  def core? = core

  ALL = YAML.load_file(Rails.root.join("config/modules.yml")).map { |key, m|
    new(key:, name: m["name"], icon: m["icon"], group: m["group"],
        core: m.fetch("core", false), path: m["path"] || "/#{key}")
  }.freeze

  BY_KEY = ALL.index_by(&:key).freeze

  def self.all = ALL
  def self.[](key) = BY_KEY[key.to_s]
  def self.optional = ALL.reject(&:core?)
  def self.grouped  = ALL.group_by(&:group)
end
