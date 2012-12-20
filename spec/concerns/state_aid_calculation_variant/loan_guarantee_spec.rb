require 'spec_helper'

describe StateAidCalculationVariant::LoanGuarantee do
  it_behaves_like 'StateAidCalculationVariant' do
    it { to_param.should == 'loan_guarantee' }
    it { page_header.should == 'Amend Draw Down Details' }
    it { leave_state_aid_calculation_path.should == loan_path(loan) }

    it 'instantiates an Flashes::StateAidCalulationFlashMessage' do
      message = double('Flashes::StateAidCalulationFlashMessage')
      Flashes::StateAidCalculationFlashMessage.should_receive(:new).with(state_aid_calculation).and_return(message)
      update_flash_message.should == message
    end
  end
end
