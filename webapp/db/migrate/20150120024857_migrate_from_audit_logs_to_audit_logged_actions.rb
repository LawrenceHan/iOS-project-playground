class MigrateFromAuditLogsToAuditLoggedActions < ActiveRecord::Migration
  def change
    database_name = ActiveRecord::Base.connection.current_database

    ActiveRecord::Base.connection.execute <<-EOF
      INSERT INTO audit.logged_actions(
        action,
        relid,
        table_name,
        row_data,
        changed_fields,
        schema_name,
        session_user_name,
        action_tstamp_tx,
        action_tstamp_stm,
        action_tstamp_clk,
        event_id,
        transaction_id,
        application_name,
        client_addr,
        client_port,
        statement_only
      )
      SELECT
        replace(upper(substring(action, 1, 1)), 'C', 'I') as action,
        record_id as relid,
        record_type as table_name,
        record_before_attributes as row_data,
        record_changes as changed_fields,
        '#{database_name}' as schema_name,
        'carevoice' as session_user_name,
        created_at as action_tstamp_tx,
        created_at as action_tstamp_stm,
        created_at as action_tstamp_clk,
        nextval('audit.logged_actions_event_id_seq') as event_id,
        txid_current() as transaction_id,
        current_setting('application_name') as application_name,
        inet_client_addr() as client_addr,
        inet_client_port() as client_port,
        't' as statement_only
      FROM audit_logs;
    EOF
  end
end
