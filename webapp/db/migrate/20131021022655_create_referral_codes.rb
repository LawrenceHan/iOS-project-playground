class CreateReferralCodes < ActiveRecord::Migration
  def change
    create_table :referral_codes do |t|
      t.string :code
      t.string :memo
      t.integer :medical_experiences_count, default: 0

      t.timestamps
    end
  end
end
