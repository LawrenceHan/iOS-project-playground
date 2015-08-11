class MergeSymptomsConditions < ActiveRecord::Migration
  SYMPTOM_ID_INC = 10000

  def up
    create_table "health_conditions" do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "category"
      t.string   "type", limit: 30
    end

    execute <<-SQL
CREATE OR REPLACE FUNCTION array_increment(int[], int)
RETURNS int[]
AS
$$
DECLARE
   arr ALIAS FOR $1;
   inc ALIAS FOR $2;
   retVal int[];
BEGIN
   FOR I IN array_lower(arr, 1)..array_upper(arr, 1) LOOP
    retVal[I] := arr[I] + inc;
   END LOOP;
RETURN retVal;
END;
$$
LANGUAGE plpgsql 
   STABLE 
RETURNS NULL ON NULL INPUT;
    SQL

    execute "INSERT INTO health_conditions SELECT * FROM symptoms"
    execute "UPDATE health_conditions SET type = 'Symptom', id = id + #{SYMPTOM_ID_INC}"
    execute "INSERT INTO health_conditions SELECT * FROM conditions"
    execute "UPDATE health_conditions SET type = 'Condition' WHERE type IS NULL"

    execute "SELECT SETVAL('health_conditions_id_seq', (SELECT MAX(id) FROM health_conditions))"

    execute "UPDATE medical_experiences SET symptom_ids = array_increment(symptom_ids, #{SYMPTOM_ID_INC}) WHERE symptom_ids IS NOT NULL"
  end

  def down
    drop_table :health_conditions
    execute "UPDATE medical_experiences SET symptom_ids = array_increment(symptom_ids, -#{SYMPTOM_ID_INC}) WHERE symptom_ids IS NOT NULL"
    execute "DROP FUNCTION IF EXISTS array_increment(int[], int);"
  end
end
