require 'spec_helper'

describe LoanSecurity do

  describe "#loan_security_type" do
    let(:loan_security) { FactoryGirl.create(:loan_security, loan_security_type_id: 7) }

    it "should return the correct loan security type" do
      loan_security.loan_security_type.should == LoanSecurityType.find(7)
    end
  end

end
