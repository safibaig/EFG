require 'spec_helper'

describe 'data correction' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }
  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, sortcode: '123456') }

  [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded].each do |state|
    it "is navigable from #{state} state" do
      loan.update_attribute :state, state
      visit_data_corrections
    end
  end

  describe 'creation' do
    before do
      visit_data_corrections
    end

    context 'sortcode' do
      before do
        click_link 'Sortcode'
      end

      it do
        fill_in 'sortcode', '654321'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.change_type_id.should == ChangeType::DataCorrection.id
        data_correction.created_by.should == current_user
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.old_sortcode.should == '123456'
        data_correction.sortcode.should == '654321'

        loan.reload
        loan.sortcode.should == '654321'
        loan.modified_by.should == current_user
      end
    end

    it 'does not show DTI demand fields when loan is not in Demanded state' do
      pending
      visit_data_corrections
      page.should_not have_css("#data_correction_dti_demand_outstanding")
      page.should_not have_css("#data_correction_dti_demand_interest")
    end

    context 'with loan in Demanded state' do
      let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :demanded, dti_interest: Money.new(1_000_00)) }

      it 'can update DTI demand outstanding amount' do
        pending
        visit_data_corrections

        fill_in 'dti_demand_out_amount', '8000'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_out_amount.should == Money.new(10_000_00)
        data_correction.dti_demand_out_amount.should == Money.new(8_000_00)
        data_correction.change_type_id.should == ChangeType::DataCorrection.id
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.created_by.should == current_user

        loan.reload
        loan.dti_demand_outstanding.should == Money.new(8_000_00)
        loan.modified_by.should == current_user
      end

      it 'can update DTI demand interest for SFLG loans' do
        loan.update_attribute(:loan_scheme, Loan::SFLG_SCHEME)
        pending

        visit_data_corrections

        fill_in 'dti_demand_interest', '500'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_interest.should == Money.new(1_000_00)
        data_correction.dti_demand_interest.should == Money.new(500_00)
        data_correction.change_type_id.should == ChangeType::DataCorrection.id
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.created_by.should == current_user

        loan.reload
        loan.dti_interest.should == Money.new(500_00)
        loan.modified_by.should == current_user
      end

      it 'can update DTI demand interest for Legacy SFLG loans' do
        pending
        loan.loan_scheme = Loan::SFLG_SCHEME
        loan.loan_source = Loan::LEGACY_SFLG_SOURCE
        loan.save!

        visit_data_corrections

        fill_in 'dti_demand_interest', '500'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_interest.should == Money.new(1_000_00)
        data_correction.dti_demand_interest.should == Money.new(500_00)
        data_correction.change_type_id.should == ChangeType::DataCorrection.id
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.created_by.should == current_user

        loan.reload
        loan.dti_interest.should == Money.new(500_00)
        loan.modified_by.should == current_user
      end
    end
  end

  private
    def visit_data_corrections
      visit loan_path(loan)
      click_link 'Data Correction'
    end

    def fill_in(attribute, value)
      page.fill_in "data_correction_#{attribute}", with: value
    end
end
