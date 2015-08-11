class AddDefaultForTypeToHealthConditions < ActiveRecord::Migration
  def up
    change_column :health_conditions, :type, :string, limit: 30, default: 'HealthCondition', null: false
  end

  def down
    change_column :health_conditions, :type, :string, limit: 30
  end
end
