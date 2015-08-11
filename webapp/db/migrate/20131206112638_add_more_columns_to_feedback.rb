class AddMoreColumnsToFeedback < ActiveRecord::Migration
  def change
    add_column :feedback, :app_version, :string
    add_column :feedback, :device_model, :string
    add_column :feedback, :system_version, :string
  end
end
