class CreateCommonSearches3 < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS materialized_aggregated_searches;"
    execute "DROP VIEW IF EXISTS aggregated_searches;"
    execute "DROP VIEW IF EXISTS common_searches;"

    filename = File.expand_path('../views/common_searches_3.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

    filename = File.expand_path('../views/aggregated_searches_8.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename)
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS materialized_aggregated_searches;"
    execute "DROP VIEW IF EXISTS aggregated_searches;"
    execute "DROP VIEW IF EXISTS common_searches;"

    filename = File.expand_path('../views/common_searches_2.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

    filename = File.expand_path('../views/aggregated_searches_8.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename)
  end
end
