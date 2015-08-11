class AddAvgWaitingTimeToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :avg_waiting_time, :integer
  end
end
