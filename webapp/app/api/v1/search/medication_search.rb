module V1::Search
  module MedicationSearch
    class API < Grape::API

      helpers CommonHelper

      # before do
      #   authenticate!
      # end

      resource :medications do
        desc 'Return medications matched by params[:name], used for autocomplete input'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :name, type: String, desc: 'Medication name'
        end
        get do
          medications = Medication.where('UPPER(name) like UPPER(:name) or UPPER(code) like UPPER(:name)', name: "%#{params[:name]}%").page(params[:page])
          append_total_pages(medications.total_pages)
          say_succeed medications.as_json(only:[:id, :name], methods: :companies)
        end
      end

    end
  end
end
