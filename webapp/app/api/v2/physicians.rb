module V2::Physicians
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    resource :hospitals do
      params do
        requires :hospital_id, type: Integer, desc: "Hospital ID"
      end
      segment '/:hospital_id' do
        resource '/:physicians' do
          get '/' do
            hospital = Hospital.find params[:hospital_id]
            physicians = hospital.physicians.includes(:department)
            physicians.where!(id: params[:physician_ids]) if params[:physician_ids].present?
            say_succeed physicians.map { |physician|
              if I18n.locale.to_s == 'zh-CN'
                { id: physician.id, name: physician.translations.map(&:name).join(' / '), department_name: physician.department_name }
              else
                { id: physician.id, name: physician.name, department_name: physician.department_name }
              end
            }
          end
        end
      end
    end

    resource :physicians do

      # totally copy from v1
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
              :vendor_id,
              :doc
            ],
            methods: [
              :human_avg_waiting_time,
              :human_avg_price,
              :human_specialities,
              :age,
              :thumb_avatar,
              :has_doc,
              :department_name,
              :department_phone,
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
        reviews = PhysicianReview.includes(:profile, :physician).where(reviewable_id: params[:id]).order("created_at DESC").page(params[:page])
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
            :human_symptoms,
            :human_health_conditions,
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
      # end -- totally copy from v1

      desc "Return a physician's doc using a vendor id as uuid"
      params do
        requires :vendor_id, type: String, desc: "Physician vendor ID"
      end
      get ':vendor_id/doc', requirements: { vendor_id: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ } do
        if physician = Physician.select(:hospital_id, :doc).select(Physician.review_count_sql).find_by(vendor_id: params[:vendor_id])
          say_succeed physician.doc_with_hospital_name
        else
          say_failed I18n.t('api.record_not_found_by_vendor_id', vendor_id: params[:vendor_id], stuff: Physician.model_name.human)
        end
      end
    end
  end
end
