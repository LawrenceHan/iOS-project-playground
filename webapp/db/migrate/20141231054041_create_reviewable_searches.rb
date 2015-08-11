class CreateReviewableSearches < ActiveRecord::Migration
  def up
    filename = File.expand_path('../views/reviewable_searches.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')

    execute "DROP VIEW IF EXISTS aggregated_searches;"

    filename = File.expand_path('../views/aggregated_searches_5.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
  end

  def down
    execute "DROP VIEW IF EXISTS reviewable_searches;"

    execute "DROP VIEW IF EXISTS aggregated_searches;"

    filename = File.expand_path('../views/aggregated_searches_4.sql', File.dirname(__FILE__))
    # remove UTF-8 BOM
    execute IO.read(filename).gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
  end
end
