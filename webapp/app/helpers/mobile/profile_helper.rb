module Mobile::ProfileHelper
  def with_optional_path
    send("mobile_#{@record.class.model_name.singular}_path", with_optional: true)
  end

  def without_optional_path
    send("mobile_#{@record.class.model_name.singular}_path")
  end

  def physician_position_and_gender(physician)
    [physician.position, I18n.t(physician[:gender])].compact.join(' | ')
  end
end
