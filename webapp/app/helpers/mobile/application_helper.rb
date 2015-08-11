module Mobile::ApplicationHelper

  def page_title
    t('title.default') + (t :"title.#{controller_name}.#{action_name}")
  end

  def separator_tag
    render 'mobile/shared/separator_tag'
  end

  # render the naviagation bar with the optional 'title' as a hash param, and
  # a block to customize the right button
  # set 'skip_menu: true' to skip navigation menu icon on the left
  def navigation_bar(locals={}, &block)
    locals = { title: nil, back: nil, skip_menu: nil }.merge(locals)
    if block
      render({ layout: 'mobile/shared/navigation',  locals: locals }, &block)
    else
      render({ partial: 'mobile/shared/navigation',  locals: locals })
    end
  end

  #  *Example of equivalent code:*
  #  = f.button class: 'button' do
  #    = image_tag 'mobile/yellow_button.svg', class: 'bg'
  #    .icons-login.button-icon
  #    = 'Login'
  #
  #  * opts:
  #  ** bg: bacground class
  #  ** icon: icon class, can be nil
  #  ** opts: will be passed to the form.button method or link_to method
  #
  #  * Block:
  #    Any aditionall mark up you would like to add
  #
  def action_button(text, opts={})
    opts = { bg: 'yellow' }.merge(opts)
    locals = { text: text, opts: opts }

    inner_html = image_tag("mobile/#{opts[:bg]}_button.svg", class: 'bg')
    inner_html << content_tag(:div, nil, class: "button-icon #{opts[:icon]}") if opts[:icon]
    inner_html << content_tag(:span, text, class: 'button-text')
    inner_html << capture_haml do
      yield(inner_html)
    end if block_given?

    method_opts = opts[:opts] || {}
    if method_opts[:class]
      method_opts[:class] += ' button'
    else
      method_opts[:class] = 'button'
    end

    if opts[:form]
      opts[:form].button inner_html, method_opts
    elsif opts[:type] == :button
      button_tag inner_html, method_opts
    else
      link_to inner_html, opts[:href], method_opts
    end
  end

  def switch_tag(name, value=false)
    label_content = I18n.locale == :en ? ActionView::Helpers::FormBuilder::SWITCH_TAG_LABEL_CONTENT : ActionView::Helpers::FormBuilder::SWITCH_TAG_LABEL_CONTENT_CN
    div_content =
      if block_given?
        yield label_content
      else
        ActiveSupport::SafeBuffer.new \
          << check_box_tag(name, 1, value, { class: 'onoffswitch-checkbox', id: name })\
          << label_tag(name, label_content, class: 'onoffswitch-label' )
      end

    content_tag(:div, div_content, class: 'onoffswitch')
  end

  # opts:
  #   editable: name of the hidden input
  def rating_stars_tag(rating, opts={})
    rating = rating.to_i
    total_stars = 5
    buffer = ActiveSupport::SafeBuffer.new

    if opts[:editable]
      (1..total_stars).each do |i|
        klass = i <= rating ? 'on' : 'off'
        buffer << content_tag(:div,
                              ActiveSupport::SafeBuffer.new \
                              << image_tag('mobile/icons/star-on.png', class: 'star-on') \
                              << image_tag('mobile/icons/star-off.png', class: 'star-off'),
                              class: "rating-star #{klass}")
      end

      buffer << content_tag(:input, nil, {type: 'hidden'}.merge(opts[:editable]))
    else
      (1..total_stars).each do |i|
        if i <= rating
          buffer << image_tag('mobile/icons/star-on.png', class: 'rating-star')
        else
          buffer << image_tag('mobile/icons/star-off.png', class: 'rating-star')
        end
      end
    end

    content_tag(:div, buffer, class: 'rating-stars unselectable')
  end

  def link_to_button(text, url=nil, options={}, &block)
    options[:class] = [options[:class], 'link-to-button'].compact.join(' ')
    bg = options.delete(:bg) || 'yellow'
    icon = options.delete(:icon)
    form = options.delete(:form)

    output = ActiveSupport::SafeBuffer.new
    output << image_tag("mobile/#{bg}_button.svg", class: 'bg')
    output << content_tag(:span, image_tag("mobile/icons/#{icon}.png"), class: 'icon') if icon
    output << content_tag(:span, text, class: 'text')
    output << capture(&block) if block_given?

    form ? form.button(output, options) : link_to(output, url, options)
  end
end
