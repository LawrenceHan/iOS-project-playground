module V1::Physicians
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    resource :physicians do
      desc "Return a physician's details"
      params do
        requires :id, type: Integer, desc: "Physician ID"
      end
      # TODO: see if there's a way to insert systematically a conversion from hashed id <-> linear id)
      get ':id', requirements: { id: /[0-9]*/ } do
        if physician = Physician.select(
            :avg_price,
            :avg_rating,
            :avg_waiting_time,
            :birthdate,
            :department_id,
            :gender,
            :hospital_id,
            :id,
            :name,
            :position,
            :doc,
            :vendor_id
          ).select(Physician.review_count_sql).find_by(id: params[:id])
          physician.name = I18n.t(physician.name, default: physician.name)
          say_succeed physician.as_json(
            only: [
              :id,
              :hospital_id,
              :name,
              :gender,
              :position,
              :avg_rating,
              :reviews_count,
              :vendor_id
            ],
            methods: [
              :human_avg_waiting_time,
              :human_avg_price,
              :human_specialities,
              :age,
              :has_doc,
              :department_name,
              :hospital_name,
              :hospital_h_class,
              :question_avg_ratings,
            ])
        else
          say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Physician.model_name.human)
        end
      end

      desc "Return a physician's reviews"
      params do
        optional :page, type: Integer, desc: 'page number'
        requires :id, type: Integer, desc: "Physician ID"
      end
      get ':id/reviews' do
        reviews = PhysicianReview.published.includes(:profile, :physician).where(reviewable_id: params[:id]).page(params[:page]).order("id desc")
        append_total_pages(reviews.total_pages)

        # Set the current user id to each reviews (for the promoted method)
        reviews.each {|r| r.current_user_id = current_user.id } if current_user

        say_succeed reviews.as_json(
          only: [
            :id,
            :created_at,
            :helpfuls_count,
            :avg_rating,
            :note
          ],
          methods: [
            :username,
            :user_id,
            :small_avatar,
            :reviewable_name,
            :physician_gender,
            :physician_position,
            :physician_avg_rating,
            :human_conditions,
            :promoted
          ])
      end

      desc "Return a physician's doc using the internal id"
      params do
        requires :id, type: String, desc: "Physician internal ID"
      end
      get ':id/doc', requirements: { id: /[0-9]*/ } do
        if physician = Physician.select(
          :hospital_id, :doc
        ).select(
          Physician.review_count_sql
        ).where(id: params[:id]).first
          say_succeed physician.doc_with_hospital_name
        else
          say_failed I18n.t('api.record_not_found', id: params[:id], stuff: Physician.model_name.human)
        end
      end

      desc "Return a physician's doc using a vendor id"
      params do
        requires :vendor_id, type: String, desc: "Physician vendor ID"
      end
      get ':vendor_id/doc', requirements: { vendor_id: /[A-Z][0-9]*/ } do
        if physician = Physician.select(:hospital_id, :doc).select(Physician.review_count_sql).find_by(vendor_id: params[:vendor_id])
          say_succeed physician.doc_with_hospital_name
        else
          say_failed I18n.t('api.record_not_found_by_vendor_id', vendor_id: params[:vendor_id], stuff: Physician.model_name.human)
        end
      end

    end
  end
end
