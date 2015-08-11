class UserMailer < ActionMailer::Base
  helper ApplicationHelper

  layout 'email', except: :to_new_user

  # NOTICE: If use smtp, default from email address must equal to :user_name in smtp settings.
  default from: APP_CONFIG[:mailer][:mailer_sender]

  def confirm_email(email, token)
    @email = email
    @token = token
    mail(to: email, subject: '【康语】请确认你的账号')
  end

  def reset_password(email, token)
    @email = email
    @token = token
    mail(to: email, subject: I18n.t("user_mailer.reset_password.subject"), template_path: "user_mailer/#{APP_CONFIG[:node]}")
  end

  def feedback_notify(email, feedback)
    @email = email
    @feedback = feedback
    mail(to: Admin.pluck(:email), subject: '【康语】新的用户反馈')
  end

  def to_new_user(email, locale = :en)
    @email = email
    headers['X-SMTPAPI'] = "{\"category\": \"Welcome New User #{APP_CONFIG[:node].capitalize}\"}"
    #mail(to: email, subject: I18n.t("user_mailer.to_new_user.subject"), template_path: "user_mailer/#{APP_CONFIG[:node]}")
    I18n.locale = locale
    @link = I18n.t("user_mailer.to_new_user.link")
    @image = I18n.t("user_mailer.to_new_user.image")
    mail(to: email, subject: I18n.t("user_mailer.to_new_user.subject"), template_path: "user_mailer/events")
  end

  def invite(from, to)
    @from = from
    @to = to
    mail(to: to, subject: '您的朋友邀请您来试用 康语App')
  end

  def to_already_thanked_user(email)
    @email = email
    mail(to: email, subject: '邀请朋友注册康语，免费获取礼品！')
  end

  def to_survey_user(email)
    mail(to: email, subject: 'The CareVoice is now available on your mobile', template_path: 'user_mailer/india')
  end
end
