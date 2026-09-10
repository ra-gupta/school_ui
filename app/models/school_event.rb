# The events a school can notify about. Each carries the default wording used
# when the school has not written its own template, so a fresh install notifies
# correctly before anyone opens the Communications module.
#
# Constants sit in the reopened `class` body for the reason given in
# SchoolModule: inside a Data.define block they would land on Object.
SchoolEvent = Data.define(:key, :name, :audience, :default_body)

class SchoolEvent
  ALL = [
    new(key: "attendance_absent", name: "Marked absent", audience: "parents",
        default_body: "{{student}} was marked absent on {{date}}. Please contact the class teacher if this is unexpected."),
    new(key: "homework_assigned", name: "Homework assigned", audience: "parents",
        default_body: "New homework for {{section}}: {{title}}. Due {{due_on}}."),
    new(key: "fee_due", name: "Fee reminder", audience: "parents",
        default_body: "Fees of {{amount}} for {{student}} are due on {{due_date}} (invoice {{number}})."),
    new(key: "bus_approaching", name: "Bus approaching", audience: "parents",
        default_body: "The school bus is approaching {{stop}}. Expected in a few minutes."),
    new(key: "notice_published", name: "Notice published", audience: "all",
        default_body: "{{title}} — {{body}}")
  ].freeze

  BY_KEY = ALL.index_by(&:key).freeze

  def self.all = ALL
  def self.[](key) = BY_KEY[key.to_s]
  def self.keys = BY_KEY.keys
end
