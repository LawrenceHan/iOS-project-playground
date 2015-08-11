require 'httparty'

module GeoFetcher
  extend ActiveSupport::Concern

  included do
    # before_save :fill_lat_and_lng
  end

  module ClassMethods
    def fill_lat_and_lng
      where(latitude: 0, longitude: 0).find_each(batch_size: 20) do |hospital|
        hospital.fill_lat_and_lng
        hospital.save if hospital.changed?
      end
    end
  end

  def address_with_city
    "#{self.city.presence || '上海市'}#{self.address}"
  end

  def update_geo_from_remote
    return if self.address.blank?
    address = URI.encode(self.address)
    city = URI.encode(self.city.presence || '上海市')
    api_response = ::ActiveSupport::JSON.decode(HTTParty.get("http://api.map.baidu.com/geocoder/v2/?address=#{address}&city=#{city}&output=json&ak=#{APP_CONFIG[:baidu_ak]}").body) rescue {}
    if api_response['result'].present? && (geo = api_response['result']['location']).present?
      self.latitude = geo['lat']
      self.longitude = geo['lng']
    end
  end

  def fill_lat_and_lng
    self.update_geo_from_remote if self.latitude.zero? && self.longitude.zero?
  end

end
