class AddDescriptionToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :description, :text

    Physician.add_translation_fields! description: :text
  end
end
