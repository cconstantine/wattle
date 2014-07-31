class FilterParams
  attr_accessor :params

  DEFAULT_FILTERS = {state: ['active', 'muffled']}.with_indifferent_access

  def initialize(params)
    self.params = params
  end

  def filters
    params[:filters].present? ? params.require("filters").permit! : DEFAULT_FILTERS
  end

  def checked? param, key
    return true unless has_filter?(param)
    filters[param].include?(key)
  end

  def has_filter? param
    filters[param].present?
  end

  def [](k)
    filters[k]
  end

  def []=(k,v)
    filters[k] = v
  end
end
