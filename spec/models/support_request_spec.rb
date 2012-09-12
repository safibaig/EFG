require 'spec_helper'

describe SupportRequest do

  describe 'validations' do
    let(:support_request) { SupportRequest.new }

    it "requires a message" do
      support_request.message = nil
      support_request.should_not be_valid

      support_request.message = "help!"
      support_request.should be_valid
    end
  end

end
