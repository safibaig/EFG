require 'spec_helper'

describe StateAidCalculationVariant::LoanEntry do
  it_behaves_like 'StateAidCalculationVariant' do
    it { to_param.should == 'loan_entry' }
    it { page_header.should == 'State Aid Calculator' }
    it { leave_state_aid_calculation_path.should == new_loan_entry_path(loan) }
    it { update_flash_message.should be_nil }
  end
end
