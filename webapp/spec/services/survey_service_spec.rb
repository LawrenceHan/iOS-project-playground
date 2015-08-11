require 'rails_helper'
require 'spec_helper'

describe SurveyService do

  before do
    @hospital   = create :hospital, name: 'hospital 1'

    speciality1 = create :speciality
    I18n.locale = 'zh-CN'
    speciality1.name = '儿科专业'
    speciality1.save
    I18n.locale = :en
    speciality1.name = 'Pediatrics'
    speciality1.save

    speciality2 = create :speciality
    I18n.locale = 'zh-CN'
    speciality2.name = '产科专业'
    speciality2.save
    I18n.locale = :en
    speciality2.name = 'OB/GYN'
    speciality2.save

    speciality3 = create :speciality, name: 'speciality 3'

    physician1 = create :physician, hospital: @hospital
    I18n.locale = 'zh-CN'
    physician1.name = '胡一君'
    physician1.save
    I18n.locale = :en
    physician1.name = 'Raphael Hu'
    physician1.save

    physician2  = create :physician, hospital: @hospital
    I18n.locale = 'zh-CN'
    physician2.name = '黄秉璋'
    physician2.save
    I18n.locale = :en
    physician2.name = 'Ping Chueng'
    physician2.save

    physician3  = create :physician, hospital: @hospital
    I18n.locale = 'zh-CN'
    physician3.name = '许宁'
    physician3.save
    I18n.locale = :en
    physician3.name = 'Kristine Xu'
    physician3.save

    physician4  = create :physician, hospital: @hospital, name: 'physician 4'

    create :physicians_speciality, speciality: speciality1, physician: physician1, priority: 3
    create :physicians_speciality, speciality: speciality2, physician: physician1, priority: 2
    create :physicians_speciality, speciality: speciality3, physician: physician1, priority: 1

    create :physicians_speciality, speciality: speciality1, physician: physician2, priority: 2
    create :physicians_speciality, speciality: speciality2, physician: physician2, priority: 3
    create :physicians_speciality, speciality: speciality3, physician: physician2, priority: 1

    create :physicians_speciality, speciality: speciality1, physician: physician3, priority: 1
    create :physicians_speciality, speciality: speciality2, physician: physician3, priority: 2
    create :physicians_speciality, speciality: speciality3, physician: physician3, priority: 3

    # no speciality for physician 4

    @survey_service = SurveyService.new hospital_name: 'hospital 1'
  end

  it "translate from survey.en.yml survey.titles" do
    expect(
      @survey_service.send(:translate, '邮箱')
    ).to eq(
      '邮箱(Email)'
    )
  end

  it "translate from survey.en.yml survey.ratings" do
    expect(
      @survey_service.send(:translate, '急待改进')
    ).to eq(
      '急待改进(Not satisfied)'
    )
  end

  it "translate from en.yml" do
    expect(
      @survey_service.send(:translate, '服务态度')
    ).to eq(
      '服务态度(Attentiveness and politeness)'
    )
  end

  it "translate but miss" do
    expect(
      @survey_service.send(:translate, '不存在')
    ).to eq('不存在')
  end

  it "translate_options to translate options as an array" do
    expect(
      @survey_service.send(:translate_options, ['邮箱', '服务态度', '不存在'])
    ).to eq(
      ['邮箱(Email)', '服务态度(Attentiveness and politeness)', '不存在']
    )
  end

  it "opts_hash should return a hash to describe options" do
    expect(
      @survey_service.send(:translate_hash, '等待时间', ['无需等待', '5分钟', '10分钟'])
    ).to eq(
      "等待时间(Waiting time)" => ["无需等待(No waiting)", "5分钟(5min)", "10分钟(10min)"]
    )
  end

  it "get_hospital_id to get hospital id by hospital name" do
    expect(
      @survey_service.send(:get_hospital_id, 'hospital 1')
    ).to eq(@hospital.id)
  end

  it "get_hospital_id to get hospital id miss" do
    expect {
      @survey_service.send(:get_hospital_id, 'hospital')
    }.to raise_error("Hospital \"hospital\" not found")
  end

  it "get_physicians_by to get physicians by hospital_id" do
    expect(
      @survey_service.send(:get_physicians_by, @hospital.id)
    ).to match_array(
      ['胡一君(Raphael Hu)/儿科专业(Pediatrics)', '黄秉璋(Ping Chueng)/产科专业(OB/GYN)', '许宁(Kristine Xu)/speciality 3', 'physician 4']
    )
  end

  it "opts_from_db_field to get options as array from database" do
    create :hospital, name: 'hospital 2'
    expect(
      @survey_service.send(:opts_from_db_field, Hospital, :name)
    ).to eq(
      ['hospital 1', 'hospital 2']
    )
  end

  it "number_options generate height options by range and 'cm' unit" do
    expect(
      @survey_service.send(:number_options, (120..125), 'cm')
    ).to eq(
      ['120cm', '121cm', '122cm', '123cm', '124cm', '125cm']
    )
  end

  it "save survey definition by hospital_name" do
    golden_file_path = "#{Rails.root}/db/golden_files/survey_by_hospital_name.txt"

    # regenerate golden file
    # keep this commented when you don't need regenerate golden file
    # survey_service_golden = SurveyService.new(hospital_name: 'hospital 1')
    # File.write(golden_file_path, survey_service_golden.definition.to_yaml)
    # end regenerate golden file

    golden_file = File.read(golden_file_path)
    survey_service = SurveyService.new(hospital_name: 'hospital 1')
    expect(survey_service.definition.to_yaml).to eq(golden_file)
    expect(survey_service.hospital_name).to eq('hospital 1')

    survey_definition = survey_service.save_definition
    expect(survey_definition.definition).to eq(survey_service.definition)
    expect(survey_definition.survey_type).to eq('B2B2C')
  end

  it "save survey definition" do
    golden_file_path = "#{Rails.root}/db/golden_files/survey_b2c.txt"

    # regenerate golden file
    # keep this commented when you don't need regenerate golden file
    # survey_service_golden = SurveyService.new
    # File.write(golden_file_path, survey_service_golden.definition.to_yaml)
    # end regenerate golden file

    golden_file = File.read(golden_file_path)
    survey_service = SurveyService.new
    expect(survey_service.definition.to_yaml).to eq(golden_file)
    expect(survey_service.hospital_name).to eq(nil)

    survey_definition = survey_service.save_definition
    expect(survey_definition.definition).to eq(survey_service.definition)
    expect(survey_definition.survey_type).to eq('B2C')
  end

end
