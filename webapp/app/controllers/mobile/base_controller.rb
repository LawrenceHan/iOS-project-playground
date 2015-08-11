class Mobile::BaseController < ApplicationController
  before_action :set_locale
  layout 'mobile'
  protect_from_forgery
  respond_to :html
  helper_method  :css_namespace

  class << self
    attr_accessor :css_namespace
  end

  def default_url_options(options={})
    {}
  end

  def after_sign_in_url
    params[:return_to] || mobile_root_url
  end

  def after_sign_out_url
    mobile_root_url
  end

  def css_namespace
    @css_namespace || self.class.css_namespace || controller_name + '-controller'
  end

  # the initial medical experience is recorded once they register
  def guest_can_have_only_one_medical_experience!
    if guest_signed_in? and current_guest.medical_experiences.count >= 1
      flash[:info] = t('guest_flow.result.flash_info')
      redirect_to mobile_guest_flow_path
    end
  end


  protected
  def set_has_more_header(collection)
    headers['X-HAS-MORE'] = '1' if collection.current_page < collection.total_pages
  end

  private
  # TODO: hardcoded india, china
  # this will be a problem if we go to more markets
  # even in India, the language should not have to be English
  def set_locale
    if APP_CONFIG[:node] == "india"
      I18n.locale = :en
    elsif APP_CONFIG[:node] == "china"
      I18n.locale = :"zh-CN"
    else
      I18n.locale = I18n.default_locale
    end
  end
end
