class CreateTrackableLog < ActiveRecord::Migration
  def change
    create_table :trackable_logs do |t|
      t.json :log
      t.datetime :created_at
    end
  end
end
