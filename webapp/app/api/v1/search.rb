module V1
  module Search
    class API < Grape::API
      include Trackable

      # This namespace used for some autocomplete inputs in form
      # User type part of name, return matched items.
      namespace :search do
        mount ConditionSearch::API
        mount SymptomSearch::API
        mount HealthConditionSearch::API
        mount SpecialitySearch::API
        mount MedicationSearch::API
        mount HospitalSearch::API
        mount PhysicianSearch::API
        mount ReviewSearch::API
      end
    end
  end
end
