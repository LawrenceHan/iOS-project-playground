class FetchSocialFriends
  def self.perform
    User.update_social_friends
  end
end
