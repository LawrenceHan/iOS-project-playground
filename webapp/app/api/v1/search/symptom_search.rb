module V1::Search
  module SymptomSearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :symptoms do
        desc 'Return symptoms matched by params[:name], used for autocomplete input'
        params do
          optional :name, type: String, desc: 'Symptom name'
        end
        get do
          say_succeed Symptom.list_matched_by_name(params[:name])
        end
      end
    end
  end
end
