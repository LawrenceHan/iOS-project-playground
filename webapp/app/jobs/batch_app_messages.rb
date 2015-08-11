class BatchAppMessages
  def self.queue
    :app_messages
  end

  def self.perform(user_ids, subject, content, admin_id)
    puts "performing App Messages ..."
    admin = Admin.find admin_id
    User.where(id: user_ids).each do |user|
      puts "user_id: #{user.id}, subject: #{subject}, content: #{content}, admin_id: #{admin_id}"
      admin.send_message user, subject, content
    end
  end
end
