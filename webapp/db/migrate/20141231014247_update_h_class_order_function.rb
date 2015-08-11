class UpdateHClassOrderFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION h_class_order(h_class VARCHAR)
      RETURNS INTEGER AS $$
        SELECT (CASE WHEN h_class = '三级甲等' THEN 100
                     WHEN h_class = '三级乙等' THEN 90
                     WHEN h_class = '三级丙等' THEN 85
                     WHEN h_class = '三级' THEN 80
                     WHEN h_class = '二级甲等' THEN 70
                     WHEN h_class = '二级乙等' THEN 60
                     WHEN h_class = '二级丙等' THEN 55
                     WHEN h_class = '二级' THEN 50
                     WHEN h_class = '一级甲等' THEN 40
                     WHEN h_class = '一级乙等' THEN 30
                     WHEN h_class = '一级丙等' THEN 25
                     WHEN h_class = '一级' THEN 20
                     ELSE 10
                     END)
      $$ LANGUAGE SQL;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION h_class_order(h_class VARCHAR);
    SQL
  end
end
