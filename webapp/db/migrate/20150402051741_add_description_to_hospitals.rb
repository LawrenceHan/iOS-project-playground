class AddDescriptionToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :description, :text

    Hospital.add_translation_fields! description: :text
  end
end
