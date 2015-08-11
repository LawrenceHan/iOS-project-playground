class Audit < ActiveRecord::Base
  store_accessor :row_data, :id
  self.primary_key = 'event_id'
  self.table_name = 'audit.logged_actions'

  default_scope { order('action_tstamp_tx ASC') }

  scope :of_entity, ->(entity) {
    where(table_name: entity.class.table_name)
      .where("(row_data->>'id')::integer = #{entity.id}")
  }

  scope :of_type, ->(type) {
    where(table_name: type.table_name)
  }

  # TODO: https://github.com/thecarevoice/webapp/issues/275
  # scope :of_user, ->(user) {
  #   joins('JOIN activities ON activities.txid = audit.logged_actions.transaction_id')
  #     .where("activities.user_id = ?", user.id)
  #     .order('action_tstamp_tx ASC')
  # }

  def user
    User
      .joins('JOIN activities ON activities.user_id = users.id')
      .where('activities.txid = ?', self.transaction_id)
      .first
  end

  def creation?
    action === 'I'
  end

  def update?
    action === 'U'
  end

  def destroy?
    self.action == 'D'
  end

  def truncate?
    self.action == 'T'
  end

  alias_method :delete?, :destroy?
end