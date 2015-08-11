# This part is used for API too, different with grape API, this part will return HTML page instead of json data.
# So it's located in app/controllers/api, not app/api.
module API
  class Base < ActionController::Metal
    include AbstractController::Rendering
    include ActionView::Layouts
    append_view_path "#{Rails.root}/app/views/api"
    layout 'api'
  end
end
