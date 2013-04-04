# encoding: utf-8

require 'spec_helper'

describe 'Loan lifecycle' do

  let(:lender) { FactoryGirl.create(:lender, :with_lending_limit) }

  let(:lender_user) { FactoryGirl.create(:lender_user, lender: lender) }

  let(:cfe_user) { FactoryGirl.create(:cfe_user) }

  let!(:sic_code) { FactoryGirl.create(:sic_code) }

  let!(:ded_code) { FactoryGirl.create(:ded_code) }

  context "for new EFG loan" do

    it do
      visit root_path
      login_as_lender_user

      # Eligibility Check
      within_navigation do
        click_link "New Loan"
      end

      fill_in_valid_eligibility_check_details(lender)
      click_button 'Check'

      loan = Loan.last
      current_url.should == loan_eligibility_decision_url(loan.id)

      # Loan Entry
      click_link "View Loan Summary"
      click_link "Loan Entry"
      fill_in_valid_loan_entry_details(loan)
      click_button "Submit"
      current_url.should == complete_loan_entry_url(loan)

      # Offer Facility
      click_link "View Loan Summary"
      click_link "Offer Scheme Facility"
      fill_in_valid_loan_offer_details(loan)
      click_button "Submit"
      current_url.should == loan_url(loan)

      # Guarantee & Initial Draw
      click_link "Guarantee & Initial Draw"
      fill_in_valid_loan_guarantee_details
      click_button "Submit"
      current_url.should == loan_url(loan)

      # Loan Change
      reprofile_draws(loan)

      # Loan Data Correction - loan amount
      make_loan_data_correction(loan)

      # Demand to Borrower 1
      make_demand_to_borrower(loan)

      # Satisfy Demand to Borrower
      satisfy_lender_demand(loan)

      # Demand to Borrower 2
      make_demand_to_borrower(loan)

      # Demand Against Government Guarantee
      click_link "Demand Against Guarantee"
      fill_in_valid_loan_demand_against_government_guarantee_details(loan, ded_code)
      click_button "Submit"

      current_url.should == loan_url(loan)

      login_as_cfe_user

      # Settle Loan
      settle_loan(loan)

      login_as_lender_user

      # Recovery Made
      within_navigation do
        click_link "Loan Portfolio"
      end
      within("#settled_loans") do
        click_link "1"
      end

      click_link loan.reference
      click_link "Recovery Made"

      fill_in_valid_efg_recovery_details
      click_button 'Calculate'
      click_button 'Submit'

      # Realise Recovery
      login_as_cfe_user

      realise_recovery(loan)

      loan.reload.state.should == Loan::Realised
    end
  end

  %w(sflg legacy_sflg).each do |loan_type|
    context "for guaranteed #{loan_type.humanize} loan" do
      let!(:loan) { FactoryGirl.create(:loan, loan_type.to_sym, :offered, :guaranteed, lender: lender, sortcode: '03-12-45') }

      it do
        visit root_path
        login_as_lender_user

        within_navigation do
          click_link "Loan Portfolio"
        end
        within("#guaranteed_loans") do
          click_link "1"
        end
        click_link loan.reference

        # Loan Change
        reprofile_draws(loan)

        # Loan Data Correction - loan amount
        make_loan_data_correction(loan)

        # Demand to Borrower 1
        make_demand_to_borrower(loan)

        # Satisfy Demand to Borrower
        satisfy_lender_demand(loan)

        # Demand to Borrower 2
        make_demand_to_borrower(loan)

        # Demand Against Government Guarantee
        click_link "Demand Against Guarantee"
        fill_in_valid_loan_demand_against_government_guarantee_details(loan, ded_code)
        fill_in 'loan_demand_against_government_dti_interest', with: 5000 # sflg specific field
        fill_in 'loan_demand_against_government_dti_break_costs', with: 2000 # sflg specific field
        click_button "Submit"

        current_url.should == loan_url(loan)

        login_as_cfe_user

        # Settle Loan
        settle_loan(loan)

        login_as_lender_user

        # Recovery Made
        within_navigation do
          click_link "Loan Portfolio"
        end
        within("#settled_loans") do
          click_link "1"
        end

        click_link loan.reference
        click_link "Recovery Made"

        fill_in_valid_sflg_recovery_details
        click_button 'Calculate'
        click_button 'Submit'

        # Realise Recovery
        login_as_cfe_user

        realise_recovery(loan)

        loan.reload.state.should == Loan::Realised
      end
    end
  end

  private

  def login_as_lender_user
    click_link 'Logout' if page.has_content?('Logout')
    submit_sign_in_form(lender_user.username, lender_user.password)
  end

  def login_as_cfe_user
    click_link 'Logout' if page.has_content?('Logout')
    submit_sign_in_form(cfe_user.username, cfe_user.password)
  end

  def reprofile_draws(loan)
    click_link "Change Amount or Terms"
    click_link 'Reprofile Draws'
    fill_in 'loan_change_date_of_change', with: Date.today.to_s(:screen)
    fill_in 'loan_change_initial_draw_amount', with: '9,876.54'
    click_button 'Submit'

    current_url.should == loan_url(loan)

    click_link 'Generate Premium Schedule'
    page.should have_content('£9,876.54')
    click_link "Loan #{loan.reference}"
  end

  def fill_in_valid_loan_demand_against_government_guarantee_details(loan, ded_code)
    fill_in 'loan_demand_against_government_dti_demand_outstanding', with: loan.cumulative_drawn_amount
    fill_in 'loan_demand_against_government_dti_reason', with: 'Something'
    select_option_value ded_code.code, from: 'loan_demand_against_government_dti_ded_code'
  end

  def make_loan_data_correction(loan)
    click_link "Data Correction"
    click_link 'Sortcode'
    fill_in "data_correction_sortcode", with: '654321'
    click_button "Submit"

    current_url.should == loan_url(loan)

    click_link 'Loan Changes'
    click_link 'Data correction'

    page.should have_content('03-12-45')
    page.should have_content('654321')

    click_link 'Loan Summary'
  end

  def make_demand_to_borrower(loan)
    click_link "Demand to Borrower"
    fill_in_valid_demand_to_borrower_details
    click_button "Submit"

    current_url.should == loan_url(loan)
  end

  def satisfy_lender_demand(loan)
    click_link 'Lender Demand Satisfied'
    fill_in 'loan_satisfy_lender_demand_date_of_change', with: Date.today.to_s(:screen)
    click_button 'Submit'

    current_url.should == loan_url(loan)
  end

  def settle_loan(loan)
    click_link "Invoice Received"
    select lender.name, from: 'invoice_lender_id'
    fill_in 'invoice_reference', with: '2006-SADHJ'
    select next_quarter_month_name(Date.today), from: 'invoice_period_covered_quarter'
    fill_in 'invoice_period_covered_year', with: Date.today.year
    fill_in 'invoice_received_on', with: Date.today.to_s(:screen)
    click_button "Select Loans"

    within("#settle_loan_#{loan.id}") do
      find('input[type=checkbox]').set(true)
    end

    click_button "Settle Loans"
  end

  def realise_recovery(loan)
    click_link "Recoveries Statement Received"
    select lender.name, from: 'realisation_statement_lender_id'
    fill_in 'realisation_statement_reference', with: "ABC123"
    select next_quarter_month_name(Date.today), from: 'realisation_statement_period_covered_quarter'
    fill_in 'realisation_statement_period_covered_year', with: Date.today.year
    fill_in 'realisation_statement_received_on', with: Date.today.to_s(:screen)
    click_button 'Select Loans'

    within "#recovery_#{loan.recoveries.last.id}" do
      check 'realisation_statement[recoveries_to_be_realised_ids][]'
    end

    click_button 'Realise Loans'
  end

  def next_quarter_month_name(date)
    until [3,6,9,12].include?(date.month)
      date = date.next_month
    end
    Date::MONTHNAMES[date.month]
  end

  def within_navigation(&block)
    within(".navbar-secondary", &block)
  end
end
