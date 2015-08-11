namespace :gbi do
  desc 'sync hospitals from gbi'
  task :sync_hospitals => :environment do
    key = 'gbi:sync:hospitals:update_time'
    update_time = $redis.get key || 0
    ownerships = JSON.parse(open("https://112.121.163.218:8443/v1/hospital_ownership?token=2adcd23b3e6a796ac681e4c535e7a7f5", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)['data'].
      inject({}) { |h, data| h[data["_id"]] = data["name_en"].downcase; h }
    h_classes = {
      "1" => {
        "A" => "一级甲等",
        "B" => "一级乙等",
        "C" => "一级丙等",
        "" => "一级未评"
      },
      "2" => {
        "A" => "二级甲等",
        "B" => "二级乙等",
        "C" => "二级丙等",
        "" => "二级未评"
      },
      "3" => {
        "A" => "三级甲等",
        "B" => "三级乙等",
        "C" => "三级丙等",
        "" => "三级未评"
      },
      "" => {}
    }
    while true
      content = JSON.parse(open("https://112.121.163.218:8443/v1/hospital?since_update=#{update_time}&token=2adcd23b3e6a796ac681e4c535e7a7f5&limit=20", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read)
      content['data'].each do |hospital_json|
        I18n.locale = 'en'
        hospital = Hospital.find_by(gbi_id: hospital_json['_id'])
        hospital = Hospital.find_by(official_name: hospital_json['name_cn']) unless hospital
        hospital = Hospital.new unless hospital
        hospital.gbi_id = hospital_json['_id']
        hospital.vendor_id = "G#{hospital_json['_id']}"
        hospital.official_name = hospital_json['name_en'] if hospital_json['name_en'].present?
        hospital.address = hospital_json['address_en'] if hospital_json['address_en'].present?
        hospital.website = hospital_json['website'] if hospital_json['website'].present?
        hospital.post_code = hospital_json['zip_code'] if hospital_json['zip_code'].present?
        hospital.ownership = ownerships[hospital_json['hospital']['ownership']] + '_owned' if hospital_json['hospital']['ownership'].present?
        hospital.h_class = h_classes[hospital_json['hospital']['tier'].to_i.to_s][hospital_json['hospital']['level']]
        hospital.save
        I18n.locale = 'zh-CN'
        hospital.official_name = hospital_json['name_cn'] if hospital_json['name_cn'].present?
        hospital.address = hospital_json['address_cn'] if hospital_json['address_cn'].present?
        hospital.save
        update_time = hospital_json['update_time']
        $redis.set key, update_time
      end
      break unless content['meta']['next_page_url']
    end
  end
end
