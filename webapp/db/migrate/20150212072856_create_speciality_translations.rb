class CreateSpecialityTranslations < ActiveRecord::Migration
  def up
    Speciality.create_translation_table!({
      :name => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Speciality.drop_translation_table!
  end
end
