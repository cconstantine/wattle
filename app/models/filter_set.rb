class FilterSet
  DEFAULT_FILTERS = { "state" => ["active", "muffled"] }

  attr_reader :filters

  def initialize(filters)
    @filters = filters || DEFAULT_FILTERS
  end

  def checked?(param, key)
    has_filter?(param) && filters[param].include?(key)
  end

  def has_filter?(param)
    filters[param].present?
  end

  def [](k)
    filters[k]
  end

  def []=(k,v)
    filters[k] = v
  end
end
