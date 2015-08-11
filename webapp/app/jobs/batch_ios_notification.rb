class BatchIosNotification
  def self.queue
    :apple_push_notifications
  end

  # APN.pool_size = 5

  def self.perform(tokens, notification)
    puts "performing BatchIosNotification ..."
    puts "tokens: #{tokens}, notification: #{notification}"
    Array(tokens).each do |token|
      APN.notify_sync token, notification
    end
  end
end
