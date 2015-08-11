class AddFullTextIndexToPhysicianName < ActiveRecord::Migration
  def up
    execute "CREATE INDEX physician_name_fulltext_idx ON physicians USING gin(to_tsvector('english', name))"
  end

  def down
    execute "DROP INDEX physician_name_fulltext_idx"
  end
end
