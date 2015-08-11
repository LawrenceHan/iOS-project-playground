class MaterializedAggregatedSearch < AggregatedSearch
  def self.refresh
    ActiveRecord::Base.connection.execute "REFRESH MATERIALIZED VIEW materialized_aggregated_searches"
  end
end
