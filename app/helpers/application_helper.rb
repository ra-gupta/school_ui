module ApplicationHelper
  # Module tiles are navigation, not data — tint by group so the grid reads as
  # designed rather than random.
  GROUP_TINT = {
    "Academics"  => "bg-blue-50 text-blue-700 ring-blue-100",
    "Finance"    => "bg-emerald-50 text-emerald-700 ring-emerald-100",
    "People"     => "bg-violet-50 text-violet-700 ring-violet-100",
    "Comms"      => "bg-orange-50 text-orange-700 ring-orange-100",
    "Operations" => "bg-cyan-50 text-cyan-700 ring-cyan-100",
    "System"     => "bg-slate-100 text-slate-700 ring-slate-200"
  }.freeze

  def group_tint(group) = GROUP_TINT.fetch(group, GROUP_TINT["System"])

  def rupees(amount, precision: 0) = number_to_currency(amount, unit: "₹", precision:, delimiter: ",")

  # Compact money for axis ticks and tiles: ₹2.6L, ₹58L, ₹1.2Cr
  def rupees_short(amount)
    n = amount.to_f
    case n.abs
    when 0...1_000      then "₹#{n.round}"
    when 1_000...1e5    then "₹#{(n / 1_000).round(1)}k"
    when 1e5...1e7      then "₹#{(n / 1e5).round(1)}L"
    else                     "₹#{(n / 1e7).round(2)}Cr"
    end
  end

  # Options for a belongs_to field: an explicit proc, else the association's
  # own table ordered by whatever human column it has.
  def field_collection(record, field)
    return field.options.call if field.options.respond_to?(:call)
    klass = record.class.reflect_on_association(field.name).klass
    col = (klass.column_names & %w[name title full_name]).first
    col ? klass.order(col) : klass.all
  end

  def field_label_for(object) = object.try(:name) || object.try(:title) || object.try(:full_name) || "##{object.id}"

  def delta_badge(current, previous)
    return nil if previous.to_f.zero?
    pct = ((current - previous) / previous.to_f * 100).round
    up  = pct >= 0
    tag.span("#{up ? "▲" : "▼"} #{pct.abs}%",
             class: "text-xs font-medium #{up ? "text-emerald-700" : "text-red-700"}")
  end
end
