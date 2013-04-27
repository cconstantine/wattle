module GroupingsHelper
  def representative_wat(grouping)
    grouping.wats.last
  end
end
