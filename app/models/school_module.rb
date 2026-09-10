# Static registry of installable modules, read from config/modules.yml.
#
# The constants live in a reopened `class` body, not inside the Data.define
# block: constants written in that block are scoped to Object, so two Data
# classes each defining ALL silently overwrite one another.
SchoolModule = Data.define(:key, :name, :icon, :group, :core, :path)

class SchoolModule
  ALL = YAML.load_file(Rails.root.join("config/modules.yml")).map { |key, m|
    new(key:, name: m["name"], icon: m["icon"], group: m["group"],
        core: m.fetch("core", false), path: m["path"] || "/#{key}")
  }.freeze

  BY_KEY = ALL.index_by(&:key).freeze

  def self.all = ALL
  def self.[](key) = BY_KEY[key.to_s]
  def self.optional = ALL.reject(&:core?)
  def self.grouped = ALL.group_by(&:group)

  def core? = core
end
