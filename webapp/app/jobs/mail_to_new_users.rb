class MailToNewUsers
  def self.perform
    User.mail_to_new_users
  end
end
