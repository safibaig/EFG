require 'spec_helper'

describe 'data correction' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  before { login_as(current_user, scope: :user) }

  describe 'Data Correction button' do
    [:guaranteed, :lender_demand, :demanded].each do |state|
      let(:loan) { FactoryGirl.create(:loan, state, lender: current_user.lender) }

      it "is visible when #{state}" do
        visit_data_corrections
      end
    end
  end

  describe 'demanded_amount' do
    let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender) }

    it 'is not included when loan is not in Demanded state' do
      visit_data_corrections
      page.should_not have_content('Demanded Amount')
    end
  end

  describe 'creation' do
    context 'business name' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender, business_name: 'Foo') }

      before do
        visit_data_corrections
        click_link 'Business Name'
      end

      it 'works' do
        fill_in 'business_name', 'Bar'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.change_type.should == ChangeType::BusinessName
        data_correction.created_by.should == current_user
        data_correction.date_of_change.should == Date.current
        data_correction.modified_date.should == Date.current
        data_correction.old_business_name.should == 'Foo'
        data_correction.business_name.should == 'Bar'

        loan.reload
        loan.business_name.should == 'Bar'
        loan.modified_by.should == current_user
      end
    end

    context 'sortcode' do
      let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender, sortcode: '123456') }

      before do
        visit_data_corrections
        click_link 'Sortcode'
      end

      it 'works' do
        fill_in 'sortcode', '654321'
        click_button 'Submit'

        data_correction = loan.data_corrections.last!
        data_correction.change_type.should == ChangeType::DataCorrection
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

    context 'with a Demanded loan' do
      before do
        visit_data_corrections
        click_link 'Demanded Amount'
      end

      context 'EFG' do
        let(:loan) { FactoryGirl.create(:loan, :guaranteed, :demanded, lender: current_user.lender, dti_demand_outstanding: Money.new(1_000_00)) }

        it 'can update demanded_amount' do
          page.should_not have_css('#data_correction_demanded_interest')

          fill_in 'demanded_amount', '2000'
          click_button 'Submit'

          data_correction = loan.data_corrections.last!
          data_correction.old_dti_demand_out_amount.should == Money.new(1_000_00)
          data_correction.dti_demand_out_amount.should == Money.new(2_000_00)
          data_correction.change_type.should == ChangeType::DataCorrection
          data_correction.date_of_change.should == Date.current
          data_correction.modified_date.should == Date.current
          data_correction.created_by.should == current_user

          loan.reload
          loan.dti_demand_outstanding.should == Money.new(2_000_00)
          loan.modified_by.should == current_user
        end
      end

      [:sflg, :legacy_sflg].each do |type|
        context type do
          let(:loan) { FactoryGirl.create(:loan, type, :guaranteed, :demanded, lender: current_user.lender, dti_demand_outstanding: Money.new(1_000_00), dti_interest: Money.new(100_00)) }

          it 'can update both amount and interest' do
            fill_in 'demanded_amount', '2000'
            fill_in 'demanded_interest', '1000'
            click_button 'Submit'

            data_correction = loan.data_corrections.last!
            data_correction.old_dti_demand_out_amount.should == Money.new(1_000_00)
            data_correction.dti_demand_out_amount.should == Money.new(2_000_00)
            data_correction.old_dti_demand_interest.should == Money.new(100_00)
            data_correction.dti_demand_interest.should == Money.new(1_000_00)
            data_correction.change_type.should == ChangeType::DataCorrection
            data_correction.date_of_change.should == Date.current
            data_correction.modified_date.should == Date.current
            data_correction.created_by.should == current_user

            loan.reload
            loan.dti_demand_outstanding.should == Money.new(2_000_00)
            loan.dti_interest.should == Money.new(1_000_00)
            loan.modified_by.should == current_user
          end
        end
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
