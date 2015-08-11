class CreateHospitalTranslations < ActiveRecord::Migration
  def up
    Hospital.create_translation_table!({
      :name => :string, :official_name => :string, :address => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Hospital.drop_translation_table!
  end
end
