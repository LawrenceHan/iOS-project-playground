module Mobile
  class HealthConditionsController < BaseController
    before_filter :authenticate_user_or_guest!

    #
    # 3 pages are linked here for the moment:
    #   Edit user's profile
    #   Edit a medical experience
    #   Add symptoms and/or conditions before a review search
    #
    def index
      @method = :put
      if request.path.include?('my_account')
        @scope = current_user.profile
        klass = Condition
      elsif params[:medical_experience_id]
        @scope = MedicalExperience.find(params[:medical_experience_id])
        klass = HealthCondition
      elsif request.path.include?('search/review')
        @scope = 'search_review'
        @method = :get
        klass = HealthCondition
      end

      @model_name = case @scope
                    when String; @scope
                    else;        @scope.class.name.underscore
                    end

      @health_conditions_json = klass.all.to_json(only: [:id, :name, :category, :type])
    end
  end
end
