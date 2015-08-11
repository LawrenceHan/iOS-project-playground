require 'rails_helper'

describe "sample" do

  def setup_hospital(uids)
    uids.each do |uid|
      h = create :hospital, name: 'hospital ' + uid.to_s, vendor_id: uid
      h.save
    end
  end

  def check_one_attributes(uids)
    arr = {}
    CSV.foreach("spec/tasks/sample_from_export.csv", headers: true) do |row|
      arr[row['ID'].to_i] = row
    end
    uids.each do |uid|
      hospital = Hospital.find_by(vendor_id: uid)
      expect(hospital[arr[hospital.id]['KEY']]).to eql(arr[hospital.id]['VALUE'])
    end
  end

  before(:each) do
    @uids = [
              "H00046255",
              "H00019319",
              "H00003843",
              "H00079873",
              "H00079896",
              "H00119300",
              "H00119304",
              "H00119306"
            ]
  end

  it "rake task sample:update can update one attribute by hospital with csv" do
    ActiveRecord::Base.connection.reset_pk_sequence!("hospitals")
    setup_hospital(@uids)
    Carevoice::Application.load_tasks
    Rake.application.invoke_task("sample:update[spec/tasks/sample_from_export.csv]")
    check_one_attributes(@uids)
  end
end
