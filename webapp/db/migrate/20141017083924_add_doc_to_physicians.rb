class AddDocToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :doc, :json
  end
end
