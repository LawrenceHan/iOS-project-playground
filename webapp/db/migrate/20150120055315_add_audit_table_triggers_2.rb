class AddAuditTableTriggers2 < ActiveRecord::Migration
  def up
    filename = File.expand_path('../audit/audited_tables_2.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "SELECT audit.audit_table('#{table_name}');"
    end
    filename = File.expand_path('../audit/not_audited_tables_2.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "DROP TRIGGER IF EXISTS audit_trigger_row ON #{table_name};"
      execute "DROP TRIGGER IF EXISTS audit_trigger_stm ON #{table_name};"
    end
  end

  def down
    filename = File.expand_path('../audit/audited_tables_2.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "DROP TRIGGER IF EXISTS audit_trigger_row ON #{table_name};"
      execute "DROP TRIGGER IF EXISTS audit_trigger_stm ON #{table_name};"
    end
    filename = File.expand_path('../audit/audited_tables.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "SELECT audit.audit_table('#{table_name}');"
    end
  end
end
