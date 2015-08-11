module ActionView
  module Helpers
    class FormBuilder
      SWITCH_TAG_LABEL_CONTENT = %<
        <div class="onoffswitch-inner">
          <div class="onoffswitch-active"><div class="onoffswitch-switch">Yes</div></div>
          <div class="onoffswitch-inactive"><div class="onoffswitch-switch">No</div></div>
        </div>
      >.html_safe

      SWITCH_TAG_LABEL_CONTENT_CN = %<
        <div class="onoffswitch-inner">
          <div class="onoffswitch-active"><div class="onoffswitch-switch">是</div></div>
          <div class="onoffswitch-inactive"><div class="onoffswitch-switch">否</div></div>
        </div>
      >.html_safe
      #
      # http://proto.io/freebies/onoff/
      #
      # <div class="onoffswitch">
      #     <input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="myonoffswitch" checked>
      #     <label class="onoffswitch-label" for="myonoffswitch">
      #         <div class="onoffswitch-inner">
      #             <div class="onoffswitch-active"><div class="onoffswitch-switch">ON</div></div>
      #             <div class="onoffswitch-inactive"><div class="onoffswitch-switch">OFF</div></div>
      #         </div>
      #     </label>
      # </div>
      def switch(method, options={})
        wrapper_opts = options.delete(:wrapper_opts) || {}
        if wrapper_opts[:class]
          wrapper_opts[:class] += ' onoffswitch'
        else
          wrapper_opts[:class] = 'onoffswitch'
        end

        @template.content_tag(:div, wrapper_opts) do

          ActiveSupport::SafeBuffer.new \
            << check_box(method, options.merge( class: 'onoffswitch-checkbox' )) \
            << label(method, (I18n.locale == :en ? SWITCH_TAG_LABEL_CONTENT : SWITCH_TAG_LABEL_CONTENT_CN), options.merge( class: 'onoffswitch-label' ))
        end
      end
    end
  end
end
