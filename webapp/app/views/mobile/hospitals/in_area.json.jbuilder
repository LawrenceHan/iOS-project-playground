json.array!(@hospitals) do |hospital|
  json.(hospital, :id, :name, :latitude, :longitude, :address, :distance, :avg_rating, :reviews_count)
end
