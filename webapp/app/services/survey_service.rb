class SurveyService

  @hospital_name = nil
  @definition    = nil
  RATING_OPTIONS = [
    "急待改进",
    "待改进",
    "一般",
    "较好",
    "非常好"
  ]

  def initialize params = {}
    @hospital_name  = params[:hospital_name] if params[:hospital_name].present?
    occupation      = Mobile::MyAccountHelper::OPTIONS[:occupation_cn].clone
    birthplace      = Mobile::MyAccountHelper::OPTIONS[:birthplace_cn].clone.keys
    education_level = Mobile::MyAccountHelper::OPTIONS[:education_level_cn].clone
    income_level    = Mobile::MyAccountHelper::OPTIONS[:income_level_cn].clone
    waiting_time    = Question::WAITING_TIME_OPTIONS.clone.map { |opt| opt[0] }
    # countries       = []
    # CSV.foreach("#{Rails.root}/db/countries.csv") do |row|
    #   countries.push row[1] unless row[1] == 'name'
    # end
    income_level.push('其它(Other)')
    occupation.delete('拒答（不出示）') # doesn't need 拒答（不出示）in survey
    education_level.push('其它（请注明）')
    birthplace.unshift('其他国家')

    height = number_options((120..220), 'CM')
    weight = number_options((30..160), 'KG')

    # option for deny answer
    na_option = '不填写(N/A)'
    height.unshift(na_option)
    weight.unshift(na_option)
    birthplace.unshift(na_option)
    income_level.unshift(na_option)

    definition = {}
    definition.merge! translate('邮箱') => 'input#email'
    definition.merge! translate('手机') => 'input#phone'
    definition.merge! translate('生日') => 'input#dob'
    definition.merge! translate_hash('性别', ['男(Male)', '女(Female)'])
    definition.merge! translate_hash('身高', height)
    definition.merge! translate_hash('体重', weight)
    definition.merge! translate_hash('职业', occupation)
    # definition.merge! translate_hash('国家', countries)
    definition.merge! translate_hash('出生地', birthplace)
    definition.merge! translate_hash('教育水平', education_level)
    definition.merge! translate_hash('收入水平/CNY', income_level)
    definition.merge! translate('就诊日期') => 'input#doymv'
    if @hospital_name.blank?
      hospitals = Hospital.all
      hospitals_names = hospitals.map do |hospital|
        hospital.name
      end
      definition.merge! translate('医院') => hospitals_names
    end
    definition.merge! translate_hash('公共设施', RATING_OPTIONS)
    definition.merge! translate_hash('卫生环境', RATING_OPTIONS)
    definition.merge! translate_hash('服务态度', RATING_OPTIONS)
    definition.merge! translate_hash('挂号预约', waiting_time)
    definition.merge! translate('对医院的补充意见') => 'textarea'
    if @hospital_name.blank?
      physicians = {}
      hospitals.each do |hospital|
        physicians[translate(hospital.name)] = get_physicians_by(hospital.id)
      end
      definition[translate('医生')] = physicians
    else
      definition.merge! translate_hash('医生', get_physicians(@hospital_name))
    end
    definition.merge! translate_hash('疗程效果', RATING_OPTIONS)
    definition.merge! translate_hash('问诊过程', RATING_OPTIONS)
    definition.merge! translate_hash('服务态度', RATING_OPTIONS)
    definition.merge! translate_hash('跟踪服务', RATING_OPTIONS)
    definition.merge! translate('对医生的补充意见') => 'textarea'
    definition.merge! translate('获取康语合作伙伴的活动和促销信息') => 'checkbox'
    @definition = definition
    return true
  end

  def hospital_name
    @hospital_name
  end

  def definition
    @definition
  end

  def save_definition
    SurveyDefinition.create(definition: @definition, survey_type: @hospital_name ? 'B2B2C' : 'B2C')
  end

  private

  def translate_hash title, options
    {translate(title) => translate_options(options)}
  end

  # translate

  def translate str
    str = str.to_s
    trans = I18n.t(str, default: str)
    return "#{str}(#{trans})" if str != trans
    trans = I18n.t("survey.titles.#{str}", default: str)
    return "#{str}(#{trans})" if str != trans
    trans = I18n.t("survey.ratings.#{str}", default: str)
    return "#{str}(#{trans})" if str != trans
    str
  end

  def translate_options options
    options.map do |s|
      translate s
    end
  end

  # end translate

  # get options

  def get_hospital_id hospital_name
    I18n.locale = 'zh-CN'
    if hospital = Hospital.find_by_name(hospital_name) then
      hospital.id
    else
      raise "Hospital \"#{hospital_name}\" not found"
    end
  end

  def get_physicians_by hospital_id
    physicians = Physician.where(hospital_id: hospital_id).all
    physicians.to_a.map! do |physician|
      I18n.locale = 'zh-CN'
      cn_name = physician.name
      I18n.locale = :en
      en_name = physician.name
      if cn_name != en_name
        name = "#{cn_name}(#{en_name})"
      else
        name = "#{cn_name}"
      end
      physicians_speciality = PhysiciansSpeciality.where(
        physician_id: physician.id
      ).order('priority desc').first
      if physicians_speciality.present?
        I18n.locale = 'zh-CN'
        cn_name = physicians_speciality.speciality.name
        I18n.locale = :en
        en_name = physicians_speciality.speciality.name
        if cn_name != en_name
          name = name + "/#{cn_name}(#{en_name})"
        else
          name = name + "/#{cn_name}"
        end
      end
      name
    end
  end

  def get_physicians hospital_name
    get_physicians_by(
      get_hospital_id(hospital_name)
    )
  end

  def opts_from_db_field model, key
    results = model.select(key).all
    results.to_a.map { |item| item[key] }
  end

  # number_options (120..220), 'cm'
  def number_options range, unit
    range.map do |n|
      "#{n}#{unit}"
    end
  end

  # end get options

end
