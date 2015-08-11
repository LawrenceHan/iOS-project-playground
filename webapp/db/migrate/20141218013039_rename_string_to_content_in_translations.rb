class RenameStringToContentInTranslations < ActiveRecord::Migration
  def change
    rename_column :translations, :string, :content
  end
end
