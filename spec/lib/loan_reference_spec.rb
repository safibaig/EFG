require 'spec_helper'

describe LoanReference do

  describe '#generate' do
    let(:loan) { FactoryGirl.build(:loan) }

    it "should generate reference in format {letters/numbers}{separator}{version number}" do
      reference = LoanReference.generate

      reference[0,6].should match(/\d*[A-Z]*/)
      reference[-3,3].should match(/\+\d{2}/)
    end

    it "should be unique" do
      LoanReference.stub(:create_reference_string).and_return('ABC123', 'DEF123')
      another_loan = FactoryGirl.create(:loan, reference: 'ABC123')

      loan.save!

      loan.reference.should == 'DEF123'
    end
  end

end