module V1::Search
  module HealthConditionSearch
    class API < Grape::API

      helpers CommonHelper

      resource :health_conditions do
        desc 'Return health_conditions matched by params[:name], used for autocomplete input'
        params do
          optional :name, type: String, desc: 'Health Condition (Symptom or Condition) name'
        end
        get do
          say_succeed HealthCondition.list_matched_by_name(params[:name])
        end
      end
    end
  end
end
