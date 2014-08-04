class FilterSet
  def initialize(params: params, filters: filters, default_filters: default_filters)
    @params = params
    @_filters = filters || default_filters
  end

  def filters
    return param_filters if has_param_filters?

    @_filters
  end

  def checked? param, key
    return false unless (@params.present? || @_filters.present?)
    return false unless has_filter?(param)
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

  private
  def has_param_filters?
    return false unless @params.present?
    @params[:filters].present?
  end

  def param_filters
    @params.require("filters").permit!
  end

end
