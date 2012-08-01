require 'spec_helper'

describe 'premium schedule reports' do
  let(:current_user) { FactoryGirl.create(:premium_collector_user) }
  before { login_as(current_user, scope: :user) }

  it 'works' do
    visit root_path
    click_link 'Extract premium schedule information'

    click_button 'Submit'
    page.should have_selector('.errors-on-base')

    fill_in 'start_on', '1/1/11'
    choose_radio_button 'schedule_type', 'new'
    click_button 'Submit'

    page.should have_content('Data extract found 2 rows')
    click_button 'Download'
    page.response_headers['Content-Type'].should include('text/csv')
  end

  private
    def choose_radio_button(attribute, value)
      choose "premium_schedule_report_#{attribute}_#{value}"
    end

    def fill_in(attribute, value)
      page.fill_in "premium_schedule_report_#{attribute}", with: value
    end
end
