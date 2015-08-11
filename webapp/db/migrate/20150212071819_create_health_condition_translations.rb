class CreateHealthConditionTranslations < ActiveRecord::Migration
  def up
    HealthCondition.create_translation_table!({
      :name => :string,
      :category => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    HealthCondition.drop_translation_table!
  end
end
