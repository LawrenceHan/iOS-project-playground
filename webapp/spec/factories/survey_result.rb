# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_result do
    result ({
      '邮箱(Email)' => 'myname@gmail.com',
      '电话(Mobile)' => '12341234',
      '生日(Date of birth)' => '12-30-1999',
      '性别(Gender)' => '男(Male)',
      '身高(Height)' => '175CM',
      '体重(Weight)' => '60KG',
      '职业(Occupation)' => '自由职业者(Freelance)',
      '出生地(Place of birth)' => '上海市(Shanghai)',
      '其他国家(Other country)' => '',
      '教育水平(Education)' => '其它（请注明）(Other (please specify))',
      '收入水平/CNY(Family monthly income / CNY)' => '5000 以下(Below 5000)',
      '医院点评(Hospital assessment)' => {
        'hospital 1' => {
          '医生点评(Physician assessment)' => '许宁(Kristine Xu)/speciality 3'
        }
      },
      '设施齐全(Facilities)' => '急待改进(Not satisfied)',
      '卫生情况(Cleanliness)' => '待改进(Not very satisfied)',
      '预约服务(Appointment making service)' => '一般(Average)',
      '等待时间(Waiting time)' => '较好(Quite satisfied)',
      '对医院的补充意见(Additional comments about hospital)' => '没什么好说的，太差了',
      '解释清楚准确(Explains clearly)' => '待改进(Not very satisfied)',
      '听取患者叙述(Listens patiently)' => '待改进(Not very satisfied)',
      '检查认真彻底(Thorough examination)' => '待改进(Not very satisfied)',
      '提供必要诊疗(Accurate diagnosis)' => '待改进(Not very satisfied)',
      '治疗效果明显(Treatment success)' => '待改进(Not very satisfied)',
      '对医生的补充意见(Additional comments about physician)' => '就这样吧 囧',
      '我同意由CareVoice及其合作伙伴联络我(By checking this box, I agree to be reached by The CareVoice partners.)' => 'true'
    })
  end
end
