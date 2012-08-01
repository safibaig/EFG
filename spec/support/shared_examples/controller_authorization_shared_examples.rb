shared_examples_for 'CfeUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:cfe_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'Lender-scoped controller' do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

shared_examples_for 'CfeUser-only controller' do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end

shared_examples_for 'PremiumCollectorUser-restricted controller' do
  let(:current_user) { FactoryGirl.create(:premium_collector_user) }

  before { sign_in(current_user) }

  it do
    expect {
      dispatch
    }.to raise_error(Canable::Transgression)
  end
end
