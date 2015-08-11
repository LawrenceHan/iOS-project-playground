module AdminPanel::UserHelper
  def social_links(user)
    output = ActiveSupport::SafeBuffer.new
    output << link_to(t('social_network.weibo'), admin_panel_authentication_path(user.weibo_auth), class: 'label label-primary various fancybox.ajax') if user.linked_to_weibo?
    if user.linked_to_tqq?
      output << "\n"
      output << link_to(t('social_network.tqq'), admin_panel_authentication_path(user.tqq_auth), class: 'label label-success various fancybox.ajax')
    end
    output
  end
end
