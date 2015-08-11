class Mobile::MyAccountsController < Mobile::BaseController
  before_filter :authenticate_user!

  UPDATE_PARAMS = [:weight, :height, :occupation, :city, :region, :education_level,
                   :username, :gender, :birthdate, :clear_condition_ids,
                   :avatar, :income_level, :network_visible, :condition_ids => []]

  def avatar
  end

  def personal_infos
  end

  def show
    @my_profile = true
    @user = current_user
    @profile = @user.profile.decorate
    @description_line = [
      [@profile.gender, @profile.age].reject(&:blank?).join(' '),
      @profile.height, @profile.weight, @profile.occupation
    ].reject(&:blank?).join(', ')
  end

  def settings
    @completed = current_user.reviews.count

    counts = current_user.reviews.group(:status).count
    @pending = counts['pending'].to_i
    @published = counts['published'].to_i
  end

  def edit
    @user = current_user
    @profile = @user.profile
  end

  def update
    @profile = current_user.profile
    if @profile.update(params.require(:profile).permit(UPDATE_PARAMS))
      flash[:info] = t('settings.profile_updated')
      redirect_to params[:proceed_to].presence || { action: :show }
    else
      flash.now[:error] = @profile.errors.full_messages

      case params[:from]
      when 'personal_infos', 'avatar'
        render action: params[:from]
      else
        render action: :edit
      end
    end
  end

  def get_cities_for
    options = {}
    if I18n.locale == :en
      options = Mobile::MyAccountHelper::OPTIONS[:birthplace]
    elsif I18n.locale == :"zh-CN"
      options = Mobile::MyAccountHelper::OPTIONS[:birthplace_cn]
    end

    return [] if (params[:region_name].blank? || !options.key?(params[:region_name]))
    render json: options[params[:region_name]]
  end
end
