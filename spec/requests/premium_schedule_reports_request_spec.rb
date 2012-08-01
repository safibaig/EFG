require 'spec_helper'

describe 'premium schedule reports' do
  let(:current_user) { FactoryGirl.create(:premium_collector_user) }
  before { login_as(current_user, scope: :user) }

  it 'does not continue with invalid values' do
    visit root_path
    click_link 'Extract premium schedule information'
    click_button 'Submit'
    current_path.should == premium_schedule_reports_path
  end
end
