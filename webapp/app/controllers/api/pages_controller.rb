module API
  class  PagesController < Base
    include ActionController::Redirecting

    def terms
      I18n.locale = params[:locale]
      render "pages/terms"
    end

    def invite
      @sended = false
      if params[:guests].present? && (guests = params[:guests].delete_if(&:blank?).uniq).present? && (owner = User.find_by(email: params[:owner])).present?
        owner.invite_requests.create!(emails: guests)
        guests.each do |guest|
          Invitation.exists?(owner_email: owner.email, guest_email: guest) || User.exists?(email: guest) || UserMailer.invite(owner.email, guest).deliver
        end
        @sended = true
      end
    rescue => e
      @error = e.message
      raise e
      ExceptionNotifier.notify_exception(e, env: env)
    ensure
      render "pages/invite"
    end

    alias_method :invitation, :invite

    def invited_app_address
      user = (params[:from] =~ /^\w+@\w+$/ && (User.where("email LIKE (?)", "#{params[:from]}.%").first)) || User.find_by(email: params[:from])

      user && Invitation.where(owner_email: user.email, guest_email: params[:to]).first_or_create
      # TODO: move configuration constant
      redirect_to 'https://itunes.apple.com/cn/app/kang-yu/id797314672'

    end

  end
end
