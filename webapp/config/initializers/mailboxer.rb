Mailboxer.setup do |config|

  #Configures if you application uses or not email sending for Notifications and Messages
  config.uses_emails = false

  #Configures the default from for emails sent for Messages and Notifications
  config.default_from = "no-reply@mailboxer.com"

  #Configures the methods needed by mailboxer
  config.email_method = :mailboxer_email
  config.name_method = :username

  #Configures if you use or not a search engine and which one you are using
  #Supported engines: [:solr,:sphinx]
  config.search_enabled = false
  config.search_engine = :solr

  #Configures maximum length of the message subject and body
  config.subject_max_length = 255
  config.body_max_length = 32000
end

Mailboxer::Conversation.class_eval do
  def as_json(options = {})
    current_user = options[:current_user]
    super(only: [:id, :subject, :created_at]).merge(is_read: self.is_read?(current_user), body: self.original_message.body)
  end
end
