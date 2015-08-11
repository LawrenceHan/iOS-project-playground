module V1::Search
  module ConditionSearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :conditions do
        desc 'Return conditions matched by params[:name], used for autocomplete input'
        params do
          optional :name, type: String, desc: 'Condition name'
        end
        get do
          say_succeed Condition.list_matched_by_name(params[:name])
        end
      end
    end
  end
end
