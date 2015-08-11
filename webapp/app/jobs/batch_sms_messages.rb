class BatchSmsMessages
  def self.queue
    :sms_messages
  end

  def self.perform(user_phones, content)
    puts "performing Sms Messages ..."
    user_phones.each do |user_phone|
      puts "phone: #{user_phone}, content: #{content}"
      User.send_sms content, user_phone
    end
  end
end
