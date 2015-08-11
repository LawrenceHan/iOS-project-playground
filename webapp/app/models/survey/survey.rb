module Survey
  class Survey < ActiveRecord::Base
    self.table_name = 'surveys'
    mount_uploader :logo, FileUploader

    translates :title, :description, :note, fallbacks_for_empty_translations: true

    attr_accessor :hospitals, :physician_ids

    validates :title, presence: true, uniqueness: true

    has_many :questions, -> { order("position asc") }, class_name: 'Survey::Question', dependent: :destroy
    has_many :feedbacks, class_name: 'Survey::Feedback', dependent: :destroy

    accepts_nested_attributes_for :questions, reject_if: lambda { |q| q['position'].blank? }, allow_destroy: true

    def init_survey
      init_description_and_note
      generate_questions
    end

    protected

    def generate_questions
      current_locale = I18n.locale
      position = 0

      if self.valid?
        question_english_options = ['Not satisfied', 'Not very satisfied', 'Average', 'Quite satisfied', 'Very satisfied']
        question_chinese_options = ['亟待改进', '待改进', '一般', '较好', '非常好']

        monthes_english_optiosn = %w(January Febuary March April May June July August September October November December)
        monthes_chinese_optiosn = %w(一月份 二月份 三月份 四月份 五月份 六月份 七月份 八月份 九月份 十月份 十一月份 十二月份)

        self.create_hospital_select_question(english_title: 'Hospital', chinese_title: '医院', english_hint: 'Type or select the hospital you visited', chinese_hint: '输入或选择你访问的医院', hospitals: hospitals, mandatory: true, position: (position += 1) * 5)
        ::Question.where(category: 'hospital').order('position asc').all.each do |question|
          I18n.locale = :en
          english_content = question.content
          I18n.locale = 'zh-CN'
          chinese_content = question.content
          if question.question_type == 'waiting_time'
            waiting_time_english_options = ['No waiting', '5min', '10min', '15min', '30min', '45min', '1hr', '1hr 15min', '1hr 30min', '1hr 45min', '2hr', '2hr 30min', '3hr', '3hr 30min', '4hr or more']
            waiting_time_chinese_options = %w(无需等待 5分钟 10分钟 15分钟 30分钟 45分钟 1小时 1小时15分钟 1小时30分钟 1小时45分钟 2小时 2小时30分钟 3小时 3小时30分钟 4小时或更多)
            self.create_select_question(english_title: english_content, chinese_title: chinese_content, english_options: waiting_time_english_options, chinese_options: waiting_time_chinese_options, category: 'hospital', mandatory: true, position: (position += 1) * 5)
          elsif english_content == 'clinic date'
            self.create_select_question(english_title: 'Date of your medical visit', chinese_title: chinese_content, english_options: monthes_english_optiosn, chinese_options: monthes_chinese_optiosn, category: 'hospital', mandatory: true, position: (position += 1) * 5)
          elsif english_content == 'clinic time'
            self.create_select_question(english_title: 'Time of your medical visit', chinese_title: chinese_content, english_options: %w(AM PM), chinese_options: %w(上午 下午), category: 'hospital', mandatory: true, position: (position += 1) * 5)
          else
            self.create_select_question(english_title: english_content, chinese_title: chinese_content, english_options: question_english_options, chinese_options: question_chinese_options, category: 'hospital', mandatory: true, position: (position += 1) * 5)
          end
        end
        chinese_default_value = <<-EOF
 哪种情况下你会去医院就医？
 您最青睐医院的哪一方面？
 请添加您认为最必要改善的方面。
        EOF
        english_default_value = <<-EOF
 In which circumstances did you visit this hospital?
 What did you like most about this hospital?
 Add specific areas of improvement as necessary.
        EOF
        self.create_text_area_question(english_title: 'Additional comments about hospital', chinese_title: '对医院的补充意见', english_default_value: english_default_value, chinese_default_value: chinese_default_value, category: 'hospital', mandatory: true, position: (position += 1) * 5)

        self.create_physician_select_question(english_title: 'Physician/Department', chinese_title: '医生/科室', english_hint: 'Please select a hospital first', chinese_hint: '请先选择医院', physician_ids: physician_ids, mandatory: true, position: (position += 1) * 5)
        ::Question.where(category: 'physician').order('position asc').all.each do |question|
          I18n.locale = :en
          english_content = question.content
          I18n.locale = 'zh-CN'
          chinese_content = question.content
          if question.question_type == 'waiting_time'
            waiting_time_english_options = ['5min', '10min', '15min', '20min', '30min', '45min', '1hr', '1hr 15min', '1hr 30min', '2hr or more']
            waiting_time_chinese_options = %w(5分钟 10分钟 15分钟 20分钟 30分钟 45分钟 1小时 1小时15分钟 1小时30分钟 2小时或更多)
            self.create_select_question(english_title: english_content, chinese_title: chinese_content, english_options: waiting_time_english_options, chinese_options: waiting_time_chinese_options, category: 'physician', mandatory: true, position: (position += 1) * 5)
          elsif question.question_type == 'price'
            self.create_text_field_question(english_title: english_content + " (RMB)", chinese_title: chinese_content + " (RMB)", category: 'physician', mandatory: true, position: (position += 1) * 5)
          elsif english_content == 'clinic date'
            self.create_select_question(english_title: 'Date of your medical visit', chinese_title: chinese_content, english_options: monthes_english_optiosn, chinese_options: monthes_chinese_optiosn, category: 'physician', mandatory: true, position: (position += 1) * 5)
          elsif english_content == 'clinic time'
            self.create_select_question(english_title: 'Time of your medical visit', chinese_title: chinese_content, english_options: %w(AM PM), chinese_options: %w(上午 下午), category: 'physician', mandatory: true, position: (position += 1) * 5)
          elsif english_content == 'Bedside Manner'
            self.create_select_question(english_title: english_content, chinese_title: chinese_content, english_options: question_english_options, chinese_options: question_chinese_options, english_hint: 'The attitude and conduct of a physician in the presence of a patient.', category: 'physician', mandatory: true, position: (position += 1) * 5)
          else
            self.create_select_question(english_title: english_content, chinese_title: chinese_content, english_options: question_english_options, chinese_options: question_chinese_options, category: 'physician', mandatory: true, position: (position += 1) * 5)
          end
        end
        chinese_default_value = <<-EOF
 哪种情况下你会向这位医生就医？
 您最青睐医生的哪一方面？
 请添加您认为最必要改善的方面。
        EOF
        english_default_value = <<-EOF
 In which circumstances did you consult this physician?
 What did you like most about this consultation?
 Add specific areas of improvement as necessary.
        EOF
        self.create_text_area_question(english_title: 'Additional comments about physician', chinese_title: '对医生的补充意见', english_default_value: english_default_value, chinese_default_value: chinese_default_value, category: 'physician', mandatory: true, position: (position += 1) * 5)

        self.create_text_field_question(english_title: 'Email', chinese_title: '邮箱', category: 'user', mandatory: true, position: (position += 1) * 5)
        self.create_text_field_question(english_title: 'Mobile number', chinese_title: '手机', category: 'user', mandatory: true, position: (position += 1) * 5)
        self.create_date_field_question(english_title: 'Date of birth', chinese_title: '生日', category: 'user', mandatory: true, position: (position += 1) * 5)
        self.create_select_question(english_title: 'Gender', chinese_title: '性别', english_options: %w(Male Female), chinese_options: %w(男 女), category: 'user', mandatory: true, position: (position += 1) * 5)
        height_english_options = ["N/A"] + (120..220).map { |i| "#{i}CM" }
        height_chinese_options = ["不填写"] + (120..220).map { |i| "#{i}厘米" }
        self.create_select_question(english_title: 'Height', chinese_title: '身高', english_options: height_english_options, chinese_options: height_chinese_options, category: 'user', position: (position += 1) * 5)
        weight_english_options = ["N/A"] + (30..160).map { |i| "#{i}KG" }
        weight_chinese_options = ["不填写"] + (30..160).map { |i| "#{i}公斤" }
        self.create_select_question(english_title: 'Weight', chinese_title: '体重', english_options: weight_english_options, chinese_options: weight_chinese_options, category: 'user', position: (position += 1) * 5)
        occupation_english_options = ["N/A", "Professionals", "Managing Director / Chief Executive Officer", "Manager", "Owner / partner / self-employed", "Government officials / cadres", "Worker", "Technical staff", "Housewife", "Retirement", "Student", "Unemployed", "Freelance", "Other (please specify)"]
        occupation_chinese_options = %w(不填写 专业人员 高级行政管理（董事长/总经理/行政总裁） 经理 老板/合伙人/自雇 政府人员/机关干部 工人 技术人员 家庭主妇 退休 失业/待业 学生 自由职业者 其它（请注明）)
        self.create_select_with_other_question(english_title: 'Occupation', chinese_title: '职业', english_options: occupation_english_options, chinese_options: occupation_chinese_options, category: 'user', position: (position += 1) * 5)
        birth_place_english_options = %w(N/A Other\ country Beijing Tianjing Shanghai Chongqing Anhui Fujian Gansu Guangdong Guizhou Hebei Heilongjiang Henan Hubei Hunan Jilin Jiangxi Jiangsu Liaoning Shandong Shaanxi Shanxi Sichuan Yunnan Zhejiang Qinghai Hainan Guangxi Neimenggu Ningxia Xizang Xinjiang Xianggang Aomen Taiwan)
        birth_place_chinese_options = %w(不填写 其它国家 北京市 天津市 上海市 重庆市 安徽省 福建省 甘肃省 广东省 贵州省 河北省 黑龙江省 河南省 湖北省 湖南省 吉林省 江西省 江苏省 辽宁省 山东省 陕西省 山西省 四川省 云南省 浙江省 青海省 海南省 广西 内蒙古 宁夏 西藏 新疆 香港 澳门 台湾)
        self.create_select_with_other_question(english_title: 'Place of birth', chinese_title: '出生地', english_options: birth_place_english_options, chinese_options: birth_place_chinese_options, category: 'user', position: (position += 1) * 5)
        education_english_options = ["N/A", "Senior middle school", "College", "Undergraduate", "Master's degree", "Doctor", "Other (please specify)"]
        education_chinese_options = %w(不填写 高中 大专 大学本科 硕士 博士 其它（请注明）)
        self.create_select_with_other_question(english_title: 'Education', chinese_title: '教育水平', english_options: education_english_options, chinese_options: education_chinese_options, category: 'user', position: (position += 1) * 5)
        income_english_options = ["N/A", "Below 5000", "5000 - 10000", "10000 - 20000", "20000 - 35000", "35000 - 50000", "50000 or more"]
        income_chinese_options = ["不填写", "5000 以下", "5000 至 10000", "10000 至 20000", "20000 至 35000", "35000 至 50000", "50000 以上"]
        self.create_select_question(english_title: 'Family monthly income / CNY', chinese_title: '收入水平 / CNY', english_options: income_english_options, chinese_options: income_chinese_options, category: 'user', position: (position += 1) * 5)

        I18n.locale = current_locale
        self.reload
      end
    end

    def create_text_field_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], type: 'Survey::TextFieldQuestion', category: options[:category], mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title]
    end

    def create_date_field_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], type: 'Survey::DateFieldQuestion', category: options[:category], mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title]
    end

    def create_select_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], options: options[:english_options].join(','), hint: options[:english_hint], type: 'Survey::SelectQuestion', category: options[:category], mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title], options: options[:chinese_options].join(','), hint: options[:chinese_hint]
    end

    def create_select_with_other_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], options: options[:english_options].join(','), type: 'Survey::SelectWithOtherQuestion', category: options[:category], mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title], options: options[:chinese_options].join(',')
    end

    def create_hospital_select_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], hint: options[:english_hint], options: options[:hospitals].present? ? options[:hospitals].map { |h| { id: h[:id], name: h[:english_name] } }.to_json : nil, type: 'Survey::HospitalSelectQuestion', category: 'hospital', mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title], hint: options[:chinese_hint], options: options[:hospitals].present? ? options[:hospitals].map { |h| { id: h[:id], name: h[:chinese_name] }  }.to_json : nil
    end

    def create_physician_select_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], hint: options[:english_hint], options: Array(options[:physician_ids]).join(','), type: 'Survey::PhysicianSelectQuestion', category: 'physician', mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title], hint: options[:chinese_hint]
    end

    def create_text_area_question(options)
      I18n.locale = :en
      question = self.questions.create title: options[:english_title], default_value: options[:english_default_value], type: 'Survey::TextAreaQuestion', category: options[:category], mandatory: !!options[:mandatory], position: options[:position]
      I18n.locale = 'zh-CN'
      question.update title: options[:chinese_title], default_value: options[:chinese_default_value]
    end

    def init_description_and_note
      current_locale = I18n.locale
      I18n.locale = :en
      self.update description: 'Share your experience with other patients, and tell us what you think about Shanghai Medical Centers!',
                  note: "Help us to ensure reliable reviews from real patients by completing your personal information. In addition, those information will enable you to find medical experiences shared by other patients with similar profiles on The CareVoice.<br/><br/>Note: If you don't wish to fill in one information, you can select the N/A option answer. Asterisk indicates a required field"
      I18n.locale = 'zh-CN'
      self.update description: '与其他患者分享您的体验，请对我们的服务作出评价。',
                  note: '请完善您的个人信息以确保评价真实可靠，同时可以帮助您在康语找到他人分享的医疗体验。<br/><br/>注意：如果你不想填写，请选择不填写。标星为必填项'
      I18n.locale = current_locale
    end
  end
end
