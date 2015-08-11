module V2::Account
  module Profiles
    class API < Grape::API

      helpers AuthorizeHelper

      # before do
      #   authenticate!
      # end

      resource :profiles do
        desc 'Return profile details for user with ID'
        params do
          requires :id, type: Integer, desc: "User ID."
        end
        get ':id', requirements: { id: /[0-9]*/ } do
          if user = User.find_by(id: params[:id])
            if current_user && user.id == current_user.id
              say_succeed user.profile || {}
            else
              say_succeed user.profile.public_attributes
            end
          else
            say_failed I18n.t('api.record_not_found', id: params[:id], stuff: User.model_name.human)
          end
        end

        desc 'Return my profile details [require login]'
        get :my do
          authenticate!
          say_succeed current_user.profile || {}
        end

        desc  'Update profile [require login]'
        params do
          optional :profile, type: Hash do
            optional :avatar, type: Rack::Multipart::UploadedFile, desc: 'avatar'
            optional :username, type: String, desc: 'username'
            optional :gender,  type: String, desc: 'gender'
            optional :birthdate, type: Date, desc: 'birth date'
            optional :weight, type: Float, desc: 'weight'
            optional :height, type: Float, desc: 'height'
            optional :occupation, type: String, desc: 'occupation'
            optional :education_level, type: String, desc: 'education level'
            optional :country, type: String, desc: 'country'
            optional :region, type: String, desc: 'region'
            optional :city,  type: String, desc: 'city'
            optional :network_visible,  type: Boolean, desc: 'network visible'
            optional :income_level, type: String, desc: 'income level'
            optional :interests,  type: Array, desc: 'interests'
            # what is pathway?
            optional :pathway, type: String, desc: 'pathway'
            optional :condition_ids,  type: Array, desc: 'condition ids array'
            optional :ios_device_token, type: String, desc: 'For push notifications'
          end
        end
        put :my do
          authenticate!
          profile_data = _params.require(:profile).permit!
          profile_data[:condition_ids].map!(&:to_i) if profile_data[:condition_ids].present?
          profile = current_user.profile || current_user.build_profile
          profile.assign_attributes(profile_data)
          if profile_data[:condition_ids].present? && profile_data[:condition_ids]==[0]
            profile.condition_ids = []
          end
          profile.save
          if profile.errors.empty?
            say_succeed
          else
            say_failed profile
          end
        end

      end
    end
  end
end
