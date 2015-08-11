class CreateCommonSearches < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS aggregated_searches;"

    filename = File.expand_path('../views/common_searches.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

    filename = File.expand_path('../views/aggregated_searches_6.sql', File.dirname(__FILE__))
    execute IO.read(filename)

    execute "CREATE INDEX index_aggregated_searches_on_hospital_id ON aggregated_searches USING btree (hospital_id);"
    execute "CREATE INDEX index_aggregated_searches_on_avg_rating ON aggregated_searches USING btree (avg_rating);"
    execute "CREATE INDEX index_aggregated_searches_on_reviews_count ON aggregated_searches USING btree (reviews_count);"
    execute "REFRESH MATERIALIZED VIEW aggregated_searches;"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS aggregated_searches;"

    execute "DROP VIEW IF EXISTS common_searches;"

    filename = File.expand_path('../views/aggregated_searches_5.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
  end
end
