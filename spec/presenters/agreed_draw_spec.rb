require 'spec_helper'

describe AgreedDraw do
  describe 'validations' do
    let(:agreed_draw) { FactoryGirl.build(:agreed_draw) }

    it 'has a valid factory' do
      agreed_draw.should be_valid
    end

    it 'strictly requires a created_by' do
      expect {
        agreed_draw.created_by = nil
        agreed_draw.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a date_of_change' do
      agreed_draw.date_of_change = ''
      agreed_draw.should_not be_valid
    end

    context '#agreed_draw' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

      it 'must be present' do
        agreed_draw.amount_drawn = ''
        agreed_draw.should_not be_valid
      end

      it 'must be positive' do
        agreed_draw.amount_drawn = '-0.01'
        agreed_draw.should_not be_valid
      end

      it 'must be less than the remaining undrawn amount' do
        agreed_draw.amount_drawn = '100,000'
        agreed_draw.should_not be_valid
      end
    end
  end

  describe '#save' do
    let(:user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }
    let(:agreed_draw) {
      FactoryGirl.build(:agreed_draw,
        loan: loan,
        created_by: user,
        amount_drawn: Money.new(1_000_00),
        date_of_change: '1/1/11'
      )
    }

    it do
      expect {
        agreed_draw.save.should == true
      }.to change(LoanChange, :count).by(1)

      loan_change = loan.loan_changes.last!
      loan_change.amount_drawn.should == Money.new(1_000_00)
      loan_change.change_type.should == ChangeType::RecordAgreedDraw
      loan_change.created_by.should == user
      loan_change.date_of_change.should == Date.new(2011)
      loan_change.modified_date.should == Date.current

      loan.reload
      loan.last_modified_at.should be_within(1).of(Time.now)
      loan.modified_by.should == user
    end
  end
end
