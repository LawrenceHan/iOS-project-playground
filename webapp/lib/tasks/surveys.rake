require 'rake'

namespace :surveys do

  class HelperFunctions

    def self.generate hospital_name
      I18n.locale = 'zh-CN'
      puts "message: start generate survey definition for #{hospital_name}"
      hospital = Hospital.find_by_name(hospital_name)
      if hospital.present?
        I18n.locale = :en
        hospital_id = hospital.id
        if (SurveyDefinition.find_by_hospital_id(hospital_id).blank?)
          sd = SurveyDefinition.new
          sd.definition = SurveyService.new(hospital_name: hospital_name).definition
          sd.hospital_id = hospital_id
          sd.save
          puts 'succeed: survey definition generated'
        else
          puts 'abort: already exist'
        end
      else
        puts 'failed: hospital not found'
      end
    end

  end

  desc 'Generate all surveys'
  task :generate_all => :environment do
    HelperFunctions.generate '美华妇儿服务'
    HelperFunctions.generate '上海天坛普华医院'
    HelperFunctions.generate '上海新瑞医疗中心'
    HelperFunctions.generate '上海瑞和门诊部'
  end

  desc 'Old survey report'
  task :old_survey_report => :environment do
    CSV.open("surveys.csv", "wb") do |csv|
      fields = SurveyResult.last.result.keys
      csv << fields + ['hospital']
      SurveyResult.all.each do |survey_result|
        result = survey_result.result
        I18n.locale = 'zh-CN'
        chinese_name = survey_result.survey_definition.hospital.name
        I18n.locale = 'en'
        english_name = survey_result.survey_definition.hospital.name
        csv << fields.map { |field| result[field] } + ["#{chinese_name} (#{english_name})"]
      end
    end
  end

  desc 'Export to users and reviews'
  task :export_to_users_and_reviews => :environment do
    GENDER_CONVERTER = {
      '女(Female)' => 'female',
      '男(Male)' => 'male'
    }
    RATING_CONVERTER = {
      '非常好(Very satisfied)' => 5,
      '较好(Quite satisfied)' => 4,
      '一般(Average)' => 3,
      '待改进(Not very satisfied)' => 2
    }
    def height_convert(value)
      return nil if !value || value == '不填写(N/A)'
      value.to_i / 100.0
    end
    def weight_convert(value)
      return nil if !value || value == '不填写(N/A)'
      value.to_i / 1.0
    end
    SurveyResult.find_each do |survey_result|
      result = survey_result.result
      phone = result['手机(Mobile number)']
      next unless phone
      email = result['邮箱(Email)']
      birthdate = result['生日(Date of birth)']
      gender = GENDER_CONVERTER[result['性别(Gender)']]
      height = height_convert(result['身高(Height)'])
      weight = weight_convert(result['体重(Weight)'])
      occupation = result['职业(Occupation)']
      birth_place = result['出生地(Place of birth)']
      birth_place_other = result['出生地(Place of birth)-other']
      education = result['教育水平(Education)']
      income_level = result['收入水平/CNY(Family monthly income / CNY)']
      username = Profile.generate_unique_anonymous_username
      user = if phone.present?
               User.find_by phone: phone
             elsif email.present?
               User.find_by email: email
             end
      user = User.new unless user
      user.phone = phone
      user.email = email
      user.username = username
      user.save(validate: false)
      profile = user.profile
      profile.username = username
      profile.birthdate = birthdate
      profile.gender = gender
      profile.height = height
      profile.weight = weight
      profile.occupation = occupation.sub(/\(.*\)/, '')
      if birth_place_other.present?
        profile.country = birth_place_other
      else
        profile.country = '中国'
        profile.city = birth_place.sub(/\(.*\)/, '')
        profile.region = birth_place.sub(/\(.*\)/, '')
      end
      profile.education_level = education.sub(/\(.*\)/, '')
      profile.income_level = income_level.sub(/\(.*\)/, '') if income_level != '不填写(N/A)'
      profile.save

      hospital_id = survey_result.survey_definition.hospital_id
      hospital_note = result['对医院的补充意见(Additional comments about hospital)']
      rating1 = RATING_CONVERTER[result['设施齐全(Facilities)']]
      rating2 = RATING_CONVERTER[result['卫生情况(Cleanliness)']]
      rating3 = RATING_CONVERTER[result['预约服务(Appointment making service)']]
      rating4 = ((rating1 + rating2 + rating3) / 3.0).ceil
      waiting_time = result['等待时间(Waiting time)'] == '无需等待(No waiting)' ? 0 : result['等待时间(Waiting time)'].to_i
      answers_attributes = [
        { question_id: 301, rating: rating1 },
        { question_id: 302, rating: rating2 },
        { question_id: 303, rating: rating3 },
        { question_id: 307, rating: rating4 },
        { question_id: 324, wating_time: waiting_time }
      ]
      medical_experience = user.medical_experiences.create
      hospital_review = HospitalReview.create(reviewable_id: hospital_id, note: hospital_note, answers_attributes: answers_attributes, medical_experience: medical_experience)
      hospital_review.update_attribute :created_at, survey_result.created_at

      physician_name = result['选择您的医生(Select your physician)'].sub(/\(.*\)/, '')
      hospital = Hospital.find hospital_id
      physician = hospital.physicians.find_by(name: physician_name)
      next unless physician
      physician_note = result['对医生的补充意见(Additional comments about physician)']
      rating1 = RATING_CONVERTER[result['解释清楚准确(Explains clearly)']]
      rating2 = RATING_CONVERTER[result['听取患者叙述(Listens patiently)']]
      rating3 = RATING_CONVERTER[result['检查认真彻底(Thorough examination)']]
      rating4 = RATING_CONVERTER[result['提供必要诊疗(Accurate diagnosis)']]
      rating = ((rating1 + rating2 + rating3 + rating4) / 4.0).ceil
      answers_attributes = [
        { question_id: 310, rating: rating },
        { question_id: 312, rating: rating },
        { question_id: 315, rating: rating },
        { question_id: 316, rating: rating },
      ]
      medical_experience = user.medical_experiences.create
      physician_review = PhysicianReview.create(reviewable_id: physician.id, note: physician_note, answers_attributes: answers_attributes, medical_experience: medical_experience)
      physician_review.update_attribute :created_at, survey_result.created_at
    end
  end

  desc 'add iws survey and missing hospitals and physicians'
  task :add_iws_survey => :environment do
    hospitals = []
    physician_ids = []
    [['上海瑞浦门诊部', 'Parkway Jinqiao', '百汇医疗 上海瑞浦门诊部'], ['上海百汇华鹰门诊部', 'Parkway Tomorow Square', '百汇医疗 上海百汇华鹰门诊部'],
     ['上海瑞新医疗中心', 'Parkway Shanghai Centre', '百汇医疗 上海瑞新医疗中心'], ['上海沃德医疗中心', 'Worldpath', '上海沃德医疗中心']].each do |chinese_name, english_name, display_name|
      I18n.locale = 'zh-CN'
      hospital = Hospital.find_by name: chinese_name
      I18n.locale = :en
      hospital.update name: english_name
      hospitals << { id: hospital.id, chinese_name: display_name, english_name: english_name }
    end
    [['上海哈瑞祥门诊部', 'Parkway Hongqiao', '百汇医疗 上海瑞祥门诊部'], ['上海国际医学交流中心', 'Shanghai International Medical Center (SIMC)', '上海国际医学中心']].each do |chinese_name, english_name, display_name|
      I18n.locale = :en
      hospital = Hospital.create name: english_name
      I18n.locale = 'zh-CN'
      hospital.update name: chinese_name, official_name: chinese_name
      hospitals << { id: hospital.id, chinese_name: display_name, english_name: english_name }
    end
    [['爱德华、沙顿', 'Edward Southern'], ['德克、瑞特菲德', 'Derk Rietveld'], ['莱恩、法菲尔', 'Ryan Pfeifer']].each do |chinese_name, english_name|
      %w(上海瑞浦门诊部 上海哈瑞祥门诊部 上海百汇华鹰门诊部 上海瑞新医疗中心 上海沃德医疗中心 上海国际医学交流中心).each do |hospital_name|
        hospital = Hospital.find_by name: hospital_name
        I18n.locale = :en
        physician = hospital.physicians.create name: english_name
        I18n.locale = 'zh-CN'
        physician.update name: chinese_name
        physician_ids << physician.id
      end
    end
    I18n.locale = :en
    survey = Survey::B2bSurvey.create(title: 'Institute for Western Surgery',
                                      logo: File.open(Rails.root.join('public/images/iws_survey.png')),
                                      hospitals: hospitals,
                                      physician_ids: physician_ids)
    I18n.locale = 'zh-CN'
    survey.update title: '伟斯顿医疗'
    survey.init_survey

    survey.questions.where(category: 'user').each do |question|
      question.update position: question.position + 250
    end
  end

  desc 'init surveys mandatory'
  task :init_surveys_mandatory => :environment do
    Survey::Question.where.not(title: ['Email', 'Mobile number', 'Date of birth', 'Gender']).update_all mandatory: true
  end

  desc 'add n/a to occupation and education'
  task :add_n_a => :environment do
    %w(Occupation Education).each do |title|
      I18n.locale = 'en'
      question = Survey::Question.find_by title: title
      question.update options: 'N/A,' + question.options
      I18n.locale = 'zh-CN'
      question.reload
      question.update options: '不填写,' + question.options
    end
  end

  desc 'delete date of your medical visit in survey'
  task :delete_date_of_your_medical_visit => :environment do
    I18n.locale = 'en'
    Survey::Question.where(title: 'Date of your medical visit').destroy_all
  end

  desc 'rename clinic date to date of your medical visit'
  task :rename_clinic_date_to_date_of_your_medical_visit => :environment do
    I18n.locale = 'en'
    Survey::Question.where(title: 'clinic date').each do |question|
      question.update(title: 'Date of your medical visit')
    end
  end

  desc 'rename clinic time to time of your medical visit'
  task :rename_clinic_time_to_time_of_your_medical_visit => :environment do
    I18n.locale = 'en'
    Survey::Question.where(title: 'clinic time').each do |question|
      question.update(title: 'Time of your medical visit')
    end
  end

  desc 'remove white collar / blue collar and add worker'
  task :remove_white_collar_blue_collar_and_add_worker => :environment do
    I18n.locale = 'en'
    Survey::Question.where(title: 'Occupation').each do |question|
      question.options = ["N/A", "Professionals", "Managing Director / Chief Executive Officer", "Manager", "Owner / partner / self-employed", "Government officials / cadres", "Worker", "Technical staff", "Housewife", "Retirement", "Student", "Unemployed", "Freelance", "Other (please specify)"].join(',')
      question.save
    end
    I18n.locale = 'zh-CN'
    Survey::Question.where(title: '职业').each do |question|
      question.options = %w(不填写 专业人员 高级行政管理（董事长/总经理/行政总裁） 经理 老板/合伙人/自雇 政府人员/机关干部 工人 技术人员 家庭主妇 退休 失业/待业 学生 自由职业者 其它（请注明）).join(',')
      question.save
    end
  end

  desc 'init hint to survey questions'
  task :init_hint_to_survey_questions => :environment do
    I18n.locale = 'en'
    survey_question = Survey::Question.find_by(title: 'Bedside Manner')
    survey_question.update hint: 'The attitude and conduct of a physician in the presence of a patient.'

    Survey::HospitalSelectQuestion.all.each do |question|
      I18n.locale = 'en'
      question.update hint: 'Type or select the hospital you visited'
      I18n.locale = 'zh-CN'
      question.reload.update hint: '输入或选择你访问的医院'
    end

    Survey::PhysicianSelectQuestion.all.each do |question|
      I18n.locale = 'en'
      question.update hint: 'Please select a hospital first'
      I18n.locale = 'zh-CN'
      question.reload.update hint: '请先选择医院'
    end
  end

end
