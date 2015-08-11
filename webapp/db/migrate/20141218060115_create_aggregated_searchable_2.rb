class CreateAggregatedSearchable2 < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS aggregated_searchables;"

    filename = File.expand_path('../views/aggregated_searchables_2.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
  end

  def down
    execute "DROP VIEW IF EXISTS aggregated_searchables;"
    filename = File.expand_path('../views/aggregated_searchables.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
  end
end
