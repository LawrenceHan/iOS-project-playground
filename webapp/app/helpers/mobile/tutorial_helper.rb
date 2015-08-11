module Mobile
  module TutorialHelper
    def intro_step_two?
      params[:step] == 'two'
    end

    def intro_css
      intro_step_two? ? 'step-two' : 'step-one'
    end

    def intro_button_text
      intro_step_two? ? t('intro.done') : t('intro.next')
    end

    def intro_next_path
      intro_step_two? ? mobile_sign_in_path : mobile_tutorial_welcome_path(step: 'one')
    end


    def welcome_bg_class
      step = params[:step].presence || 'one'
      "step-#{step}"
    end

    def welcome_next_step
      params[:step] == 'two' ? 'three' : 'two'
    end

    def welcome_next_path
      params[:step] == 'three' ?  mobile_tutorial_intro_path(step: 'two') : mobile_tutorial_welcome_path(step: welcome_next_step)
    end

    def step_markers
      steps = %w(one two three)
      current_step = params[:step].presence || 'one'
      output = ActiveSupport::SafeBuffer.new
      (0..2).to_a.each do |index|
        status = (steps.index(current_step) == index ? 'white' : 'off')
        output << image_tag("mobile/icons/dot-#{status}.png")
      end
      output
    end

  end
end
