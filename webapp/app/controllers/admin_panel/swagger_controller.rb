module AdminPanel
  class SwaggerController < ApplicationController
    before_action :require_admin!
    layout "swagger"
  end
end
