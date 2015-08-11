require 'rails_helper'

describe 'db:hospitals' do
  it "should have a rake task db:hospitals:merge" do
    @hospital_a = create :hospital, name: 'Hospital A'
    @hospital_b = create :hospital, name: 'Hospital B'

    Carevoice::Application.load_tasks

    expect {
      Rake.application.invoke_task("db:hospitals:merge[#{@hospital_a.id}, #{@hospital_b.id}]")
    }.to change { Hospital.count }.by(-1)

    # Handle bad arguments
    expect {
      Rake.application.invoke_task("db:hospitals:merge[-1, -2]")
    }.to change { Hospital.count }.by(0)
  end
end