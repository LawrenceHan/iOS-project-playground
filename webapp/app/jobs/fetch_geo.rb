class FetchGeo
  def self.perform
    Hospital.fill_lat_and_lng
  end
end
