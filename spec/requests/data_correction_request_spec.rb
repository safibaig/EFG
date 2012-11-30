require 'spec_helper'

describe 'data correction' do
  let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
  before { login_as(current_user, scope: :user) }
  let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, amount: Money.new(5_000_00)) }

  describe 'creation' do
    [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded].each do |state|
      it "is navigable from #{state} state" do
        loan.update_attribute :state, state
        navigate_to_data_correction_form
      end
    end

    it 'does not continue with nothing inputted' do
      navigate_to_data_correction_form
      click_button 'Submit'
      page.should have_selector('.errors-on-base')
    end

    it do
      navigate_to_data_correction_form

      fill_in 'amount', '6000'
      click_button 'Submit'

      data_correction = loan.data_corrections.last!
      data_correction.old_amount.should == Money.new(5_000_00)
      data_correction.amount.should == Money.new(6_000_00)
      data_correction.change_type_id.should == '9'
      data_correction.date_of_change.should == Date.current
      data_correction.modified_date.should == Date.current
      data_correction.created_by.should == current_user

      loan.reload
      loan.amount.should == Money.new(6_000_00)
      loan.modified_by.should == current_user
    end

    it 'does not show DTI demand fields when loan is not in Demanded state' do
      navigate_to_data_correction_form
      page.should_not have_css("#data_correction_dti_demand_outstanding")
      page.should_not have_css("#data_correction_dti_demand_interest")
    end

    context 'with loan in Demanded state' do
      let(:loan) { FactoryGirl.create(:loan, :offered, :guaranteed, :demanded, dti_interest: Money.new(1_000_00)) }

      it 'can update DTI demand outstanding amount' do
        navigate_to_data_correction_form

        fill_in 'dti_demand_out_amount', '8000'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_out_amount.should == Money.new(10_000_00)
        data_correction.dti_demand_out_amount.should == Money.new(8_000_00)
        data_correction.change_type_id.should == '9'
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.created_by.should == current_user

        loan.reload
        loan.dti_demand_outstanding.should == Money.new(8_000_00)
        loan.modified_by.should == current_user
      end

      it 'can update DTI demand interest for SFLG loans' do
        loan.update_attribute(:loan_scheme, Loan::SFLG_SCHEME)

        navigate_to_data_correction_form

        fill_in 'dti_demand_interest', '500'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_interest.should == Money.new(1_000_00)
        data_correction.dti_demand_interest.should == Money.new(500_00)
        data_correction.change_type_id.should == '9'
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.created_by.should == current_user

        loan.reload
        loan.dti_interest.should == Money.new(500_00)
        loan.modified_by.should == current_user
      end

      it 'can update DTI demand interest for Legacy SFLG loans' do
        loan.loan_scheme = Loan::SFLG_SCHEME
        loan.loan_source = Loan::LEGACY_SFLG_SOURCE
        loan.save!

        navigate_to_data_correction_form

        fill_in 'dti_demand_interest', '500'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.old_dti_demand_interest.should == Money.new(1_000_00)
        data_correction.dti_demand_interest.should == Money.new(500_00)
        data_correction.change_type_id.should == '9'
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
    def navigate_to_data_correction_form
      visit loan_path(loan)
      click_link 'Data Correction'
    end

    def fill_in(attribute, value)
      page.fill_in "data_correction_#{attribute}", with: value
    end
end
