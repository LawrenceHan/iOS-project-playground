module Mobile
  class SpecialitiesController < BaseController
    def index
      @specialities_json = Rails.cache.fetch('all_specialities', expires_in: 1.hour) do
        Speciality.order(:name).to_json
      end
    end
  end
end
