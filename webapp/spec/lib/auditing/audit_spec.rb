require 'rails_helper'

describe Audit, skip: true do
  it "all tables are either in audited or not audited" do
    max_version = Dir.glob('db/audit/audited_tables*.txt').map { |filename| filename[-5].to_i }.max
    audited_tables = File.read(Rails.root.join("db/audit/audited_tables_#{max_version}.txt")).split("\n") rescue []
    not_audited_tables = File.read(Rails.root.join("db/audit/not_audited_tables_#{max_version}.txt")).split("\n") rescue []
    expect(ActiveRecord::Base.connection.tables.sort).to eq (audited_tables + not_audited_tables).sort
  end

  it "should create a record in the audit log when a new hospital is created" do
    expect {
      hospital = create :hospital
    }.to change { Audit.count }.by(1)
    expect(Audit.all[0].table_name).to eq('hospitals')
  end

  it "should create a record in the audit log when an hospital is updated" do
    expect(Audit.of_type(Hospital).count).to eq(0),
        Audit.of_type(Hospital).pluck(:client_query, :row_data).map {|p| p.join(',')}.join('|')

    hospital = create :hospital

    expect {
      hospital.update_attributes(name: 'New hospital name')
    }.to change { Audit.count }.by(1)
    expect(Audit.all.last.table_name).to eq('hospitals')
  end

  it "should create a record in the audit log when an hospital is destroyed" do
    expect(Audit.of_type(Hospital).count).to eq(0),
        'Expect no audit logs but got ' +
        Audit.of_type(Hospital).pluck(:client_query, :row_data).map {|p| p.join(',')}.join('|')

    hospital = create :hospital

    expect {
      hospital.destroy
    }.to change { Audit.count }.by(1)

    expect(Audit.all.last.table_name).to eq('hospitals')
  end

  it "should have a audit method to access all the audit logs records associated to a record sorted by creation date" do
    hospital = create :hospital
    second_hospital = create :hospital
    hospital.update_attributes(name: 'New hospital name')

    expect(hospital.audit.count).to eq(2)
    expect(hospital.audit[0].creation?).to eq(true)
    expect(hospital.audit[1].update?).to eq(true)
  end

  it "should have helpers on Audit model to inspect the action type" do
    hospital = create :hospital
    hospital.update_attributes(name: 'New hospital name')
    hospital.destroy

    # We should have three operations in the log..
    expect(hospital.audit.count).to eq(3)

    # First the creation
    expect(hospital.audit[0].creation?).to eq(true)
    # The update
    expect(hospital.audit[1].update?).to eq(true)
    # And finally the deletion
    expect(hospital.audit[2].destroy?).to eq(true)
  end

  it "should have a record of all the attributes after the operation" do
    hospital = create :hospital, name: 'Hospital A'
    hospital.update_attributes(name: 'New hospital name A')
    hospital.destroy

    # At the creation
    expect(hospital.audit[0].creation?).to eq(true)
    expect(hospital.audit[0].row_data['id']).to eq(hospital.id)
    expect(hospital.audit[0].row_data['name']).to eq('Hospital A')

    # After an update
    expect(hospital.audit[1].update?).to eq(true)
    expect(hospital.audit[1].row_data['id']).to eq(hospital.id)
    expect(hospital.audit[1].changed_fields['name']).to eq('New hospital name A')

    # After being destroyed
    expect(hospital.audit[2].destroy?).to eq(true)
    expect(hospital.audit[2].row_data['id']).to eq(hospital.id)
    expect(hospital.audit[2].row_data['name']).to eq('New hospital name A')
  end

  it "should have a record of the attributes before the update operation" do
    hospital = create :hospital, name: 'Hospital A'
    hospital.update_attributes(name: 'New hospital name A')

    expect(hospital.audit[1].update?).to eq(true)
    expect(hospital.audit[1].row_data["id"]).to eq(hospital.id)
    expect(hospital.audit[1].row_data["name"]).to eq('Hospital A')
  end

  it "should have a record of the changes completed during the update operation" do
    hospital = create :hospital, name: 'Hospital A'
    hospital.update_attributes(name: 'New hospital name A')

    expect(hospital.audit[1].update?).to eq(true)
    expect(hospital.audit[1].changed_fields.size).to eq(2)
    expect(hospital.audit[1].row_data["name"]).to eq('Hospital A')
    expect(hospital.audit[1].changed_fields["name"]).to eq('New hospital name A')
  end


  # TODO: https://github.com/thecarevoice/webapp/issues/275
  # it "should retrieve the user that did the action on an audit log item" do
  #   user = create :user
  #   User.current_user_id = user.id

  #   hospital = create :hospital, name: 'Hospital A'

  #   expect(hospital.audit[0].user.class).to eq(User)
  #   expect(hospital.audit[0].user.id).to eq(user.id)
  # end

  # it "should be able to find audit logs by users" do
  #   user = create :user
  #   User.current_user_id = user.id

  #   hospital = create :hospital, name: 'Hospital A'

  #   expect(Audit.of_user(user).count).to eq(3)
  #   expect(Audit.of_user(user).last.row_data['id']).to eq(hospital.id)
  #   expect(Audit.of_user(user)[2].table_name).to eq('hospitals')
  # end
end
