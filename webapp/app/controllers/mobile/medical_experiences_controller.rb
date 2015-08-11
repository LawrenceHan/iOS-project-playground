class Mobile::MedicalExperiencesController < Mobile::BaseController

  PERMITTED_ATTRS = [:behalf, :network_visible, :clear_symptom_ids, :clear_condition_ids,
                     { :symptom_ids => [], :condition_ids => [] }]

  before_action :authenticate_user_or_guest!, except: [:index, :destroy]
  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :guest_can_have_only_one_medical_experience!, only: [:new, :create]


  # My medical experiences
  def index
    @medical_experiences = current_user.medical_experiences.order('updated_at DESC').page(params[:page]).per(10)
    @medical_experiences.includes!(:reviews)

    if request.xhr?
      set_has_more_header @medical_experiences
      render @medical_experiences, layout: false
    else
      @has_more = @medical_experiences.current_page < @medical_experiences.total_pages
      render
    end
  end

  def new
    session.delete :current_medical_experience_id
    @medical_experience = MedicalExperience.new(user: current_user_or_guest)
  end

  def create
    @medical_experience = current_user_or_guest.medical_experiences
      .new(params.require(:medical_experience).permit(*PERMITTED_ATTRS))

    if @medical_experience.save
      if params[:proceed_to] == 'edit_conditions'
        redirect_to mobile_medical_experience_health_conditions_path(@medical_experience)
      else
        session.delete :current_medical_experience_id
        redirect_to mobile_my_account_path
      end
    else
      render :edit
    end

  end

  def edit
    @medical_experience = current_user_or_guest.medical_experiences.find(params[:id])
    session[:current_medical_experience_id] = @medical_experience.id
  end

  def update
    @medical_experience = current_user_or_guest.medical_experiences.find(params[:id])

    attrs = params.require(:medical_experience).permit(*PERMITTED_ATTRS)

    if @medical_experience.update(attrs)
      if params[:finished]
        session.delete :current_medical_experience_id

        if current_user_or_guest.is_guest
          redirect_to mobile_guest_flow_path
        else
          redirect_to mobile_my_account_medical_experiences_path
        end
      else
        redirect_to action: :edit
      end
    else
      render :edit
    end
  end

  def destroy
    @medical_experience = current_user.medical_experiences.find(params[:id])
    if @medical_experience.destroy
      flash[:info] = t('review.medical_experience_deleted')
    end

    redirect_to mobile_my_account_medical_experiences_path
  end
end
