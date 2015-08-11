class AddFullTextIndexToHealthConditionName < ActiveRecord::Migration
  def up
    execute "CREATE INDEX health_condition_name_fulltext_idx ON health_conditions USING gin(to_tsvector('english', name))"
  end

  def down
    execute "DROP INDEX health_condition_name_fulltext_idx"
  end
end
