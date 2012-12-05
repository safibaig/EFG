shared_examples_for 'StateAidCalculationVariant' do
  include Rails.application.routes.url_helpers

  class MockController
    include Rails.application.routes.url_helpers
  end

  let(:loan) { double('Loan', to_param: 34) }
  let(:state_aid_calculation) { double('StateAidCalculation', to_param: 21) }
  let(:controller) { MockController.new.extend(subject) }
  let(:to_param) { subject.to_param }
  let(:page_header) { controller.page_header }
  let(:leave_state_aid_calculation_path) { controller.leave_state_aid_calculation_path(loan) }
  let(:update_flash_message) { controller.update_flash_message(state_aid_calculation) }

  describe "#page_header" do
    it "responds to #page_header" do
      controller.should respond_to(:page_header)
    end
  end

  describe "#leave_state_aid_calculation_path" do
    it "responds to #leave_state_aid_calculation_path" do
      controller.should respond_to(:leave_state_aid_calculation_path)
    end
  end

  describe "#update_flash_message" do
    it "responds to #update_flash_message" do
      controller.should respond_to(:update_flash_message)
    end
  end
end
