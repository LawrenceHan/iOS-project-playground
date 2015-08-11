class AddLocaleToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :locale, :string
  end
end
