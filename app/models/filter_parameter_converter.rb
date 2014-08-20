class FilterParameterConverter

  def initialize(filter_params)
    @filter_params = filter_params
  end

  # starting with: "language" => {"ruby" => "0", javascript" => "1"}
  # ending with:   "language" => ["javascript"]
  def convert
    results = {}
    @filter_params.each do |filter_type, filter_hash|
      results[filter_type] = filter_hash.reject { |_, v| v == "0" }.keys
    end
    results
  end
end
