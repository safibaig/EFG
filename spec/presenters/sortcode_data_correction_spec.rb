require 'spec_helper'

describe SortcodeDataCorrection do
  describe 'validations' do
    let(:presenter) { FactoryGirl.build(:sortcode_data_correction) }

    it 'has a valid factory' do
      presenter.should be_valid
    end

    it 'requires a sortcode' do
      presenter.sortcode = ''
      presenter.should_not be_valid
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, sortcode: '123456', last_modified_at: 1.year.ago) }
    let(:presenter) { FactoryGirl.build(:sortcode_data_correction, created_by: user, loan: loan) }

    context 'success' do
      it 'creates a DataCorrection and updates the loan' do
        presenter.sortcode = '654321'
        presenter.save.should == true

        data_correction = loan.data_corrections.last!
        data_correction.change_type_id.should == ChangeType::DataCorrection.id
        data_correction.created_by.should == user
        data_correction.sortcode.should == '654321'
        data_correction.old_sortcode.should == '123456'

        loan.reload
        loan.last_modified_at.should_not == 1.year.ago
        loan.modified_by.should == user
        loan.sortcode.should == '654321'
      end
    end

    context 'failure' do
      it 'does not update the loan' do
        presenter.sortcode = ''
        presenter.save.should == false

        loan.reload
        loan.sortcode.should == '123456'
      end
    end
  end
end
