class CreateArrayIntersectFunction < ActiveRecord::Migration
  def change
    # Select intersect
    execute <<-SQL
      CREATE OR REPLACE FUNCTION array_intersect(anyarray, anyarray)
      RETURNS anyarray AS $$
        SELECT ARRAY(SELECT unnest($1)
                     INTERSECT
                     SELECT unnest($2))
      $$ LANGUAGE sql;
    SQL
  end
end
