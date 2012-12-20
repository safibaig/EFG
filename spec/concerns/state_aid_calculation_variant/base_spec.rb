require 'spec_helper'

describe StateAidCalculationVariant::Base do
  it_behaves_like 'StateAidCalculationVariant' do
    it { page_header.should == 'State Aid Calculator' }
    it { leave_state_aid_calculation_path.should == loan_path(loan) }
    it { update_flash_message.should be_nil }
  end

  describe ".to_param" do
    it "raise a NotImplementedError" do
      expect {
        StateAidCalculationVariant::Base.to_param
      }.to raise_error(NotImplementedError, 'StateAidCalculationVariant::Base is the default')
    end
  end
end
