require 'spec_helper'

describe 'eligibility checks' do
  it "displays the eligibility check form" do
    visit root_path
    click_link 'Check Eligibility'

    current_path.should == new_loans_eligibility_check_path
  end
end
