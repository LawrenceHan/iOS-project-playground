class AddUuidToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
