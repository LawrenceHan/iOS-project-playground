module V2::Surveys
  class API < Grape::API

    helpers CommonHelper

    resource :surveys do

      desc "return a survey definition by id"
      params do
        requires :uuid, type: String, desc: "survey definition ID"
      end
      get ':uuid/definition', requirements: { uuid: /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/ } do
        if survey_definition = SurveyDefinition.find_by_uuid(params[:uuid])
          say_succeed survey_definition
        else
          say_failed I18n.t('api.record_not_found', uuid: params[:uuid], stuff: SurveyDefinition.model_name.human)
        end
      end

      desc "save a survey result"
      params do
        requires :survey_definition_id, type: Integer, desc: "ID of survey definition which relate to the result"
        requires :result, type: Hash, desc: "survey result Json"
      end
      post do
        survey_result                      = SurveyResult.new
        survey_result.result               = params[:result]
        survey_result.survey_definition_id = params[:survey_definition_id]
        if survey_result.save
          say_succeed survey_result
        else
          say_failed survey_result.errors
        end
      end

    end

  end
end
