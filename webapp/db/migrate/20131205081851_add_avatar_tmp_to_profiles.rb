class AddAvatarTmpToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :avatar_tmp, :string
  end
end
