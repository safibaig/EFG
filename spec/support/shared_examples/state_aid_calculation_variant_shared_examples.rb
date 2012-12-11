shared_examples_for 'StateAidCalculationVariant' do
  include Rails.application.routes.url_helpers

  let(:loan) { double('Loan', to_param: 34) }
  let(:state_aid_calculation) { double('StateAidCalculation', to_param: 21) }
  let(:to_param) { subject.to_param }
  let(:page_header) { subject.page_header }
  let(:leave_state_aid_calculation_path) { subject.leave_state_aid_calculation_path(loan) }
  let(:update_flash_message) { subject.update_flash_message(state_aid_calculation) }

end
