module V1::Search
  module ReviewSearch
    class API < Grape::API

      helpers CommonHelper
      helpers ReviewsHelper
      helpers AuthorizeHelper

      # before do
      #   authenticate!
      # end

      resource :reviews do
        desc 'Search reviews by type(hospital|physician|medication)'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :type, type: String, desc: 'review type, should be one of [hospital,physician,medication]', regexp: /^hospital|physician|medication$/
          optional :symptom_ids, type: Array, desc: 'ids of selected symptoms by user'
          optional :condition_ids, type: Array, desc: 'ids of selected conditions by user'
        end
        get :by_type do
          klass = get_review_class
          reviews = klass.published.search_by(
            _params.slice(:type, :symptom_ids, :condition_ids).merge(current_user_id: current_user.try(:id))
          ).order('created_at DESC').page(params[:page])

          # this logic is spread all over the code and is going to be
          # problematic if we add one more case
          if params[:type] == 'hospital'
            reviews.includes!(:hospital)
          elsif params[:type] == 'physician'
            reviews.includes!(:physician)
          elsif params[:type] == 'medication'
            reviews.includes!(:medication)
          end

          # Set the current user id to each reviews (for the promoted method)
          reviews.each {|r| r.current_user_id = current_user.id } if current_user

          append_total_pages(reviews.total_pages)
          say_succeed jsonify(reviews)
        end

        desc 'Search reviews by medication id'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :medication_id, type: Integer, desc: 'Medication ID'
        end
        get :by_medication do
          reviews = MedicationReview.published.search(current_user.try(:id)).where(reviewable_id: params[:medication_id]).page(params[:page])
          append_total_pages(reviews.total_pages)
          say_succeed jsonify(reviews)
        end

        desc 'Search reviews by hospital id'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :hospital_id, type: Integer, desc: 'Hospital ID'
        end
        get :by_hospital do
          reviews = HospitalReview.published.where(reviewable_id: params[:hospital_id]).search(current_user.try(:id)).page(params[:page])
          append_total_pages(reviews.total_pages)
          say_succeed jsonify(reviews)
        end

        desc 'Search reviews by user id'
        params do
          optional :page, type: Integer, desc: 'page number'
          requires :user_id, type: Integer, desc: 'Hospital ID'
          # FIXME: type is requires here, otherwise 500 returned
          optional :type, type: String, desc: 'Review type, should be one of [hospital,physician,medication]'
        end
        get :by_user do
          klass =
            case params[:type].downcase
            when "physician";   PhysicianReview.all.includes(:physician, :hospital)
            when "hospital";    HospitalReview.all.includes(:hospital)
            when "medication";  MedicationReview.all.includes(:medication)
            else;               Review
            end

          reviews = klass.published.joins(:user).where('users.id = ?', params[:user_id]).page(params[:page])
          reviews._select!('reviews.*')._select!("#{current_user.try(:id) || 'NULL'} current_user_id")

          reviews.includes!(:hospital, :medical_experience, :user)

          # Set the current user id to each reviews (for the promoted method)
          reviews.each {|r| r.current_user_id = current_user.id } if current_user

          append_total_pages(reviews.total_pages)
          say_succeed jsonify(reviews)
        end
      end

    end
  end
end
