# encoding: utf-8

require 'spec_helper'

describe DataCorrection do
  it_behaves_like 'LoanModification'

  describe 'validations' do
    let(:data_correction) { FactoryGirl.build(:data_correction) }

    it 'must have something set' do
      data_correction.amount = ''
      data_correction.lending_limit_id = ''
      data_correction.facility_letter_date = ''
      data_correction.initial_draw_date = ''
      data_correction.initial_draw_amount = ''
      data_correction.sortcode = ''
      data_correction.should_not be_valid
    end

    context '#amount' do
      it 'must be between £1,000 and £1,000,000' do
        data_correction.amount = '999.99'
        data_correction.should_not be_valid
        data_correction.amount = '1000000.01'
        data_correction.should_not be_valid
        data_correction.amount = '999999.99'
        data_correction.should be_valid
      end

      it 'must be >= total amount_drawn' do
        FactoryGirl.create(:loan_change, loan: data_correction.loan, amount_drawn: Money.new(3_000_00))
        FactoryGirl.create(:loan_change, loan: data_correction.loan, amount_drawn: Money.new(2_000_00))

        data_correction.amount = Money.new(4_999_99)
        data_correction.should_not be_valid
      end
    end
  end

  describe '#save_and_update_loan' do
    let(:lender) { FactoryGirl.create(:lender) }
    let(:user) { FactoryGirl.create(:lender_user, lender: lender) }
    let(:lending_limit_1) { FactoryGirl.create(:lending_limit, lender: lender) }
    let(:lending_limit_2) { FactoryGirl.create(:lending_limit, lender: lender) }
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: lender, lending_limit: lending_limit_1, amount: Money.new(5_000_00), facility_letter_date: Date.new(2012, 1, 1), sortcode: '123456') }
    let!(:initial_draw_change) {
      loan.initial_draw_change.tap { |initial_draw_change|
        initial_draw_change.amount_drawn = Money.new(1_000_00)
        initial_draw_change.date_of_change = Date.new(2012, 3, 4)
        initial_draw_change.save!
      }
    }
    let(:data_correction) {
      DataCorrection.new do |data_correction|
        data_correction.created_by = user
        data_correction.date_of_change = Date.current
        data_correction.loan = loan
        data_correction.modified_date = Date.current
      end
    }

    it 'works with #amount' do
      data_correction.amount = Money.new(6_000_00)
      data_correction.save_and_update_loan.should == true
      data_correction.old_amount.should == Money.new(5_000_00)

      loan.reload
      loan.amount.should == Money.new(6_000_00)
    end

    it 'works with #facility_letter_date' do
      data_correction.facility_letter_date = Date.new(2012, 2, 2)
      data_correction.save_and_update_loan.should == true
      data_correction.old_facility_letter_date.should == Date.new(2012, 1, 1)

      loan.reload
      loan.facility_letter_date.should == Date.new(2012, 2, 2)
    end

    it 'works with #initial_draw_amount / #initial_draw_date' do
      data_correction.initial_draw_amount = Money.new(2_000_00)
      data_correction.save_and_update_loan.should == true
      data_correction.old_initial_draw_amount.should == Money.new(1_000_00)

      initial_draw_change.reload
      initial_draw_change.amount_drawn.should == Money.new(2_000_00)
    end

    it 'works with #initial_draw_amount / #initial_draw_date' do
      data_correction.initial_draw_date = Date.new(2012, 4, 3)
      data_correction.save_and_update_loan.should == true
      data_correction.old_initial_draw_date = Date.new(2012, 3, 4)

      initial_draw_change.reload
      initial_draw_change.date_of_change.should == Date.new(2012, 4, 3)
    end

    it 'works with #lending_limit_id' do
      data_correction.lending_limit_id = lending_limit_2.id
      data_correction.save_and_update_loan.should == true
      data_correction.old_lending_limit_id.should == lending_limit_1.id

      loan.reload
      loan.lending_limit_id.should == lending_limit_2.id
    end

    it 'works with #sortcode' do
      data_correction.sortcode = '654321'
      data_correction.save_and_update_loan.should == true
      data_correction.old_sortcode.should == '123456'

      loan.reload
      loan.sortcode.should == '654321'
    end

    it 'creates a new loan state change record for the state change' do
      expect {
        data_correction.amount = Money.new(6_000_00)
        data_correction.save_and_update_loan
      }.to change(LoanStateChange, :count).by(1)

      state_change = loan.state_changes.last
      state_change.event_id.should == 22
      state_change.state.should == Loan::Guaranteed
    end
  end

  describe '#seq' do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

    it 'is incremented for each DataCorrection' do
      correction1 = FactoryGirl.create(:data_correction, loan: loan)
      correction2 = FactoryGirl.create(:data_correction, loan: loan)

      correction1.seq.should == 1
      correction2.seq.should == 2
    end
  end
end
