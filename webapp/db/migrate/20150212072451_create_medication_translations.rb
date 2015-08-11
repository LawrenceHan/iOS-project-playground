class CreateMedicationTranslations < ActiveRecord::Migration
  def up
    Medication.create_translation_table!({
      :name => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Medication.drop_translation_table!
  end
end
