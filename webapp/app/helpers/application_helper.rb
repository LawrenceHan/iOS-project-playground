module ApplicationHelper
  def api_url_for(options)
    version = CV::API.versions.last
    namespace = options.delete(:namespace).to_s
    controller = options.delete(:controller).to_s
    action = options.delete(:action).to_s

    action_with_slash = (action == 'index' || action.blank?) ? '' : "/#{action}"
    namespace_with_slash = namespace.blank? ? '' : "/#{namespace}"
    "#{host}/#{version}#{namespace_with_slash}/#{controller}#{action_with_slash}?#{options.to_query}"
  end

  def microsites_url(record)
    "/microsites/physician.html?vendor_id=#{record.vendor_id}"
  end

  def host
    "#{APP_CONFIG[:protocol]}#{APP_CONFIG[:host]}"
  end
  module_function :host
end
