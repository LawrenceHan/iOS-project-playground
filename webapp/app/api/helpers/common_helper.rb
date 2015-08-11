module CommonHelper
  def say_succeed(object_or_message=nil, options = {})
    status(options[:status] || figure_status[:success]) # Set status code

    case object_or_message
    when Hash
      object_or_message
    when String
      { message: object_or_message }
    else
      append_pagination_info(object_or_message)
      object_or_message.as_json
    end
  end

  def say_failed(object_or_message=nil)
    status(figure_status[:failure]) # Set status code

    case object_or_message
    when ActiveRecord::Base
      { error: object_or_message.errors.full_messages }
    when String
      { error: [object_or_message] }
    when Hash
      object_or_message
    end
  end

  def figure_status
    case env["REQUEST_METHOD"]
    when 'GET'    then { success: 200, failure: 400 }
    when 'POST'   then { success: 201, failure: 422 }
    when 'PUT'    then { success: 204, failure: 422 }
    when 'DELETE' then { success: 204, failure: 422 }
    end
  end

  def append_pagination_info(relation)
    if params[:page].present? and headers['X-Total-Pages'].blank? and relation.respond_to?(:total_pages)
      append_total_pages(relation.total_pages)
    end
  end

  # Append total pages to header by hand.
  def append_total_pages(total_pages)
    header 'X-Total-Pages', total_pages.to_s
  end

  def current_url
    "#{request.scheme}://#{request.host_with_port}#{request.fullpath}"
  end

  # instance of ActionController::Parameters, can be apply strong parameters features
  def _params
    ActionController::Parameters.new(params.to_hash)
  end

  def get_params_data(oject_name, columns)
    _params.require(oject_name.to_sym).permit(*columns)
  end

  def session
    env['rack.session']
  end
end
