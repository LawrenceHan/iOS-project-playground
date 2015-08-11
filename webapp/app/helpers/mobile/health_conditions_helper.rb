module Mobile::HealthConditionsHelper
  def url_for_scope(scope)
    if scope.is_a?(Profile)
      mobile_my_account_path
    elsif scope == 'search_review'
      mobile_search_review_search_menu_path
    else
      url_for [:mobile, scope]
    end
  end
end
