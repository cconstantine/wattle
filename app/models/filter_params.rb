class FilterParams
  DEFAULT_FILTERS = {state: ['active', 'muffled']}.with_indifferent_access

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def filters
    return param_filters if has_param_filters?

    default_filters
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

  private
  def has_param_filters?
    @params[:filters].present?
  end

  def param_filters
    @params.require("filters").permit!
  end

  def default_filters
    @current_user.try(:default_filters) || DEFAULT_FILTERS
  end

end
