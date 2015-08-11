module AdminPanel::ReferralCodeHelper
  def new_tr_color
    request.xhr? ? 'success' : nil
  end
end
