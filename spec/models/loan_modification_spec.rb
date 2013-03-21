require 'spec_helper'

describe LoanModification do
  describe '#changes' do
    let(:loan_modification) { FactoryGirl.build(:data_correction) }

    it 'contains only fields that have a value' do
      loan_modification.old_business_name = 'Foo'
      loan_modification.business_name = 'Bar'

      loan_modification.changes.size.should == 1
      loan_modification.changes.first[:attribute].should == 'business_name'
    end
  end
end
