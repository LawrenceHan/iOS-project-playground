module V1::Search
  module SpecialitySearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :specialities do
        desc 'Return all specialities with physician count for each speciality'
        params do
          optional :page, type: Integer, desc: 'page number'
        end
        get do
          specialities = Speciality.joins(:physicians).select('specialities.id, specialities.name, count(physicians.*) AS physicians_count').group('specialities.id, specialities.name')
          say_succeed specialities.as_json(only: [:id, :name, :physicians_count])
        end
      end
    end
  end
end
