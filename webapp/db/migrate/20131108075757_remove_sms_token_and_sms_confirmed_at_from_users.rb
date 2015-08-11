class RemoveSmsTokenAndSmsConfirmedAtFromUsers < ActiveRecord::Migration
  def change
    remove_columns(:users, :sms_token, :sms_confirmed_at)
  end
end
