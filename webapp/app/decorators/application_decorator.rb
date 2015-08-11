class ApplicationDecorator < Draper::Decorator
  def translate(*args)
    key = args.first
    if key.is_a?(String) && (key[0] == '.')
      key = "decorators.#{object.class.model_name.i18n_key}.#{ key }"
      args[0] = key
    end

    I18n.translate(*args)
  end

  alias_method :t, :translate
end
