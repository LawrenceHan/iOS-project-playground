class CreateDepartmentTranslations < ActiveRecord::Migration
  def up
    Department.create_translation_table!({
      :name => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Department.drop_translation_table!
  end
end
