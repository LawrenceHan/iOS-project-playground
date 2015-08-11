module AdminPanel::HospitalHelper
  def human_departments(hospital)
    hospital.departments.map(&:name).join(',')
  end

  def ownership_collection
    Hospital.ownerships.inject({}) { |h, (k, _)| h[I18n.t(k)] = k; h }
  end
end
