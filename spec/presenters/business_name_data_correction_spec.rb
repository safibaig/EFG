require 'spec_helper'

describe BusinessNameDataCorrection do
  describe 'validations' do
    let(:presenter) { FactoryGirl.build(:business_name_data_correction) }

    it 'has a valid factory' do
      presenter.should be_valid
    end

    it 'requires a business_name' do
      presenter.business_name = ''
      presenter.should_not be_valid
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, business_name: 'Foo') }
    let(:presenter) { FactoryGirl.build(:business_name_data_correction, created_by: user, loan: loan) }

    context 'success' do
      it 'creates a DataCorrection and updates the loan' do
        presenter.business_name = 'Bar'
        presenter.save.should == true

        data_correction = loan.data_corrections.last!
        data_correction.created_by.should == user
        data_correction.change_type_id.should == ChangeType::BusinessName.id
        data_correction.business_name.should == 'Bar'
        data_correction.old_business_name.should == 'Foo'

        loan.reload
        loan.business_name.should == 'Bar'
        loan.modified_by.should == user
      end
    end

    context 'failure' do
      it 'does not update loan' do
        presenter.business_name = nil
        presenter.save.should == false
        loan.reload

        loan.business_name.should == 'Foo'
      end
    end
  end
end
