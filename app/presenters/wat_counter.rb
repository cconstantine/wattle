class WatCounter
  attr_accessor :scale
  attr_writer :groupings

  def initialize(scale)
    self.scale = scale
  end

  def format(relation)
    relation.count.map do |aggregate_key, count|
      { period: Array(aggregate_key).first,
        period_length: scale,
        count: count }.merge(grouped_columns(aggregate_key))
    end
  end

  def group(*groups)
    self.groupings += groups
    wats.group(*groups)
  end

  def wats
    date_segment = Wat.send(:sanitize_conditions,["date_trunc(?, created_at)",scale])
    grouped_query = Wat.group(date_segment)
    #order by the time column(2nd), since we cant predict the aggregate alias assigned by ActiveRecord
    grouped_query.order('2 desc')
  end

  protected

  def groupings
    @groupings ||= []
  end

  def grouped_columns(aggregate_key)
    Hash[*groupings.zip(Array(aggregate_key)[1, groupings.length]).flatten]
  end

end
