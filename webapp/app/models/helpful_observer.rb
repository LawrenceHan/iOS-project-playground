class HelpfulObserver < ActiveRecord::Observer
  def after_create(helpful)
    user = helpful.review.user
    if user && (token = user.profile.ios_device_token)
      alert = I18n.t('push_notifications.helpful', to_user: user.username, user: helpful.user.username)
      APN.notify_async(token, alert: alert, review_id: helpful.review.id.to_s)
    end
  end
end
