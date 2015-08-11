module Mobile
  module GuestFlowHelper
    def completion_pie(completion, options={})
      @completion_pie ||= {}
      @completion_pie[completion] ||= begin
        percentage = number_to_percentage(completion * 100, precision: 0)
        content_tag(:div, class: 'completion') do
          concat(pie(completion, options))
          concat(
            capture do
              content_tag(:div, class: 'percentage') do
                concat t('common.complete')
                concat content_tag(:div, percentage)
              end
            end
          )
        end
      end
    end

    # Draw a pie with completion
    # args:
    #   completion: float, like 0.21, 1.0
    #   options: pie style options
    #     `:radius`: pie radius
    #     `:color` : pie background color
    #     `:wrapper`: a bigger pia wrapper
    #       `:border`: wrapper border width
    #       `:color` : wrapper background color
    def pie(completion, options={})
      @pie ||= {}
      @pie[completion] ||= begin
        r = options[:radius] || 200
        cx, cy = [r] * 2
        width, height = [r * 2] * 2
        color = options[:color] || '#f28e25'
        angle = (completion >= 1 ? 0.00001 : completion.to_f) * Math::PI
        big = (completion.to_f > 0.5 ? 1 : 0)

        if options[:wrapper]
          wrapper_border = (options[:wrapper].is_a?(Hash) && options[:wrapper][:border]) || 20
          cx += wrapper_border
          cy += wrapper_border
          width += wrapper_border * 2
          height += wrapper_border * 2
          wrapper_r = r + wrapper_border
          wrapper_color = (options[:wrapper].is_a?(Hash) && options[:wrapper][:color]) || '#034858'
        end

        x1 = cx - r * Math.sin(angle);
        y1 = cy + r * Math.cos(angle);
        x2 = cx + r * Math.sin(angle);
        y2 = cy + r * Math.cos(angle);

        d = "M #{cx},#{cy} L #{x1},#{y1} A #{r},#{r} 0 #{big} 0 #{x2},#{y2} Z"
        output = %{<svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="#{width}px" height="#{height}px" viewBox="0 0 #{width} #{height}" enable-background="new 0 0 #{width} #{height}" xml:space="preserve" preserveAspectRatio="none">}
        output << %{<circle cx="#{cx}" cy="#{cy}" r="#{wrapper_r}" stroke-width="0" fill="#{wrapper_color}"/>} if options[:wrapper]
        output << %{<g stroke-width="0"><path d="#{d}" fill="#{color}"/></g></svg>}
        output.html_safe
      end
    end

    def reviewable_avatar(type)
      case type
      when 'HospitalReview' then image_tag('mobile/reviews/hospital_avatar.png')
      when 'PhysicianReview' then image_tag('mobile/reviews/physician_avatar.png')
      when 'MedicationReview' then image_tag('mobile/reviews/medication_avatar.png')
      end
    end
  end
end
