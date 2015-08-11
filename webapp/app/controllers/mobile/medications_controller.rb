module Mobile
  class MedicationsController < BaseController
    def index
      if params[:drug_name].present?
        @medications = AggregatedSearch.search(query: { type: 'Medication', text: params[:drug_name] }).map { |searchable|
          entity = searchable.searchable_entity
          entity.distance = searchable.attributes['distance'] if searchable.attributes['distance']
          entity.avg_rating = searchable.attributes['avg_rating']
          entity.reviews_count = searchable.attributes['reviews_count']
          entity
        }.uniq

        @medications = Kaminari.paginate_array(@medications).page(params[:page])
        @has_more = @medications.current_page < @medications.total_pages
      end

      if request.xhr?
        set_has_more_header @medications
        render @medications, layout: false
      else
        render
      end
    end

    def show
      # real-life dosage is probably more complex than this model?
      @record = Medication.select(:id, :name, :code, :dosage1, :dosage2, :dosage3, :avg_rating).select(Medication.review_count_sql).find_by(id: params[:id])

      @required_questions, @optional_questions = @record.question_avg_ratings, []

      render 'profile'
    end


    def css_namespace
      action_name == 'show' ? 'physicians-controller' : super
    end

  end
end
