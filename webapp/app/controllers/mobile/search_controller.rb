class Mobile::SearchController < Mobile::BaseController
  def index
  end

  def physician
  end

  def review
    type = params[:type].presence || 'hospital'
    klass = Mobile::ReviewsHelper.review_class(type)

    if search = params[:search_review]
      params.merge!(search)
    end

    @reviews = klass.published.search_by(params.slice(:type, :symptom_ids, :condition_ids)
      .merge(current_user_id: current_user.try(:id))).page(params[:page]).per(10)
    @reviews.includes!(:hospital) if type == 'hospital'
    @reviews.includes!(:physician) if type == 'physician'
    @reviews.includes!(:medication) if type == 'medication'


    if request.xhr?
      set_has_more_header @reviews
      render partial: 'review', collection: @reviews, layout: false
    else
      @has_more = @reviews.current_page < @reviews.total_pages
      render
    end

  end

  def review_add_conditions
  end
end
