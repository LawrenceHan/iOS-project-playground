module Mobile::RegistrationsHelper
  def gender_btn_class(profile)
    if profile[:gender] == 'female'
      {male: 'icons-left_off gender_btn', female: 'icons-right_on gender_btn'}
    else
      {male: 'icons-left_on gender_btn', female: 'icons-right_off gender_btn'}
    end
  end

  def yes_or_no_for(interest)
    @profile.has_interest?(interest) ?
      content_tag(:div, t('common._yes'), class: 'yes_btn pull-right') :
      content_tag(:div, t('common._no'), class: 'no_btn pull-right')
  end

  def registration_step_markers
    steps = %w(step_one step_two step_three)
    output = ActiveSupport::SafeBuffer.new
    (0..2).to_a.each do |index|
      status = (steps.index(action_name) == index ? 'on' : 'off')
      output << image_tag("mobile/icons/dot-#{status}.png", class: 'step-dot')
    end
    output
  end
end
