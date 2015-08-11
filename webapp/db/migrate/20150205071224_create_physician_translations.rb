class CreatePhysicianTranslations < ActiveRecord::Migration
  def up
    Physician.create_translation_table!({
      :name => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Physician.drop_translation_table!
  end
end
