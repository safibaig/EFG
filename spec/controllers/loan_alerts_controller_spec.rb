require 'spec_helper'

describe LoanAlertsController do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  before { sign_in(current_user) }

  describe "#not_drawn" do
    let!(:high_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, facility_letter_date: 190.days.ago) }
    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, facility_letter_date: 180.days.ago) }
    let!(:low_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, facility_letter_date: 140.days.ago) }

    def dispatch(params = {})
      get :not_drawn, params
    end

    it_behaves_like "loan alerts controller"
    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "#not_demanded" do
    let!(:high_priority_loan) { FactoryGirl.create(:loan, :lender_demand, :sflg, lender: current_lender, borrower_demanded_on: 360.days.ago) }
    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :lender_demand, :legacy_sflg, lender: current_lender, borrower_demanded_on: 350.days.ago) }
    let!(:low_priority_loan) { FactoryGirl.create(:loan, :lender_demand, :sflg, lender: current_lender, borrower_demanded_on: 310.days.ago) }
    # EFG loans are excluded from this loan alert
    let!(:efg_loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender, borrower_demanded_on: 310.days.ago) }

    def dispatch(params = {})
      get :demanded, params
    end

    it_behaves_like "loan alerts controller"
    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "#not_progressed" do
    let!(:high_priority_loan) { FactoryGirl.create(:loan, :eligible, lender: current_lender, updated_at: 180.days.ago) }
    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :completed, lender: current_lender, updated_at: 170.days.ago) }
    let!(:low_priority_loan) { FactoryGirl.create(:loan, :incomplete, lender: current_lender, updated_at: 130.days.ago) }

    def dispatch(params = {})
      get :not_progressed, params
    end

    it_behaves_like "loan alerts controller"
    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "#assumed_repaid" do
    let!(:high_priority_incomplete_loan) { FactoryGirl.create(:loan, :incomplete, lender: current_lender, maturity_date: 180.days.ago) }
    let!(:high_priority_guaranteed_loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender, maturity_date: 90.days.ago) }
    let!(:medium_priority_completed_loan) { FactoryGirl.create(:loan, :completed, lender: current_lender, maturity_date: 170.days.ago) }
    let!(:medium_priority_guaranteed_loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender, maturity_date: 70.days.ago) }
    let!(:low_priority_offered_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, maturity_date: 125.days.ago) }
    let!(:low_priority_guaranteed_loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_lender, maturity_date: 40.days.ago) }

    def dispatch(params = {})
      get :assumed_repaid, params
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context "with high priority" do
      before do
        dispatch(priority: :high)
      end

      it "loads only high priority loans" do
        assigns(:loans).size.should == 2
        assigns(:loans).should include(high_priority_incomplete_loan)
        assigns(:loans).should include(high_priority_guaranteed_loan)
      end
    end

    context "with medium priority" do
      before do
        dispatch(priority: :medium)
      end

      it "loads only medium priority loans" do
        assigns(:loans).size.should == 2
        assigns(:loans).should include(medium_priority_completed_loan)
        assigns(:loans).should include(medium_priority_guaranteed_loan)
      end
    end

    context "with low priority" do
      before do
        dispatch(priority: :low)
      end

      it "loads only low priority loans" do
        assigns(:loans).size.should == 2
        assigns(:loans).should include(low_priority_offered_loan)
        assigns(:loans).should include(low_priority_guaranteed_loan)
      end
    end

    context "with no priority" do
      before do
        dispatch
      end

      it "loads only low priority loans" do
        loans = assigns(:loans)

        assigns(:loans).size.should == 6
        loans.should include(high_priority_incomplete_loan)
        loans.should include(high_priority_guaranteed_loan)
        loans.should include(medium_priority_completed_loan)
        loans.should include(medium_priority_guaranteed_loan)
        loans.should include(low_priority_offered_loan)
        loans.should include(low_priority_guaranteed_loan)
      end
    end
  end
end
