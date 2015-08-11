class AddAuditTableTriggers < ActiveRecord::Migration
  def up
    filename = File.expand_path('../audit/audit.sql', File.dirname(__FILE__))
    execute IO.read(filename)
    filename = File.expand_path('../audit/audited_tables.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "SELECT audit.audit_table('#{table_name}');"
    end
  end

  def down
    filename = File.expand_path('../audit/audited_tables.txt', File.dirname(__FILE__))
    IO.read(filename).each_line do |table_name|
      execute "DROP TRIGGER audit_trigger_row ON #{table_name};"
      execute "DROP TRIGGER audit_trigger_stm ON #{table_name};"
    end
    execute "DROP SCHEMA audit CASCADE;"
  end
end
