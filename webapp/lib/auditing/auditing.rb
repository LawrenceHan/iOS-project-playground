module Auditing
  extend ActiveSupport::Concern

  included do
    class_eval do
      after_create :audit_user!
      after_update :audit_user!
      after_destroy :audit_user!
    end
  end

  def audit
    Audit.of_entity(self)
  end

  def audit_user!
    if User.current_user_id
      # only interested if the user has changed since the last time
      txid = ActiveRecord::Base.connection.execute('SELECT txid_current() AS txid')[0]['txid'].to_i
      if Thread.current[:auditing_user] != txid
        Thread.current[:auditing_user] = txid
        Activity.create(user_id: User.current_user_id, txid: txid)
      end
    end
  end
end

class ActiveRecord::Base
  include Auditing
end

require File.join(File.dirname(__FILE__), 'audit')

