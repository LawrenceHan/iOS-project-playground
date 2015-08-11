require 'rails_helper'

describe MedicationReview do

  it 'creates a mailboxer message for cardinal health review but no coupon' do
    coupon = create(:coupon, code: '1234567890', source: 'cardinal_health', used: true)
    expect {
      cardinal_health = create(:cardinal_health)
      medication = create(:medication, cardinal_health: cardinal_health)
      create :medication_review, medication: medication
    }.to change { Mailboxer::Message.count }.by(1)
    coupon.reload
    expect(coupon.user).to be_nil
    expect(coupon.created_by).to be_nil
  end

  it 'does not create a mailboxer message for normal review' do
    expect {
      create :medication_review
    }.not_to change { Mailboxer::Message.count }
  end
end
