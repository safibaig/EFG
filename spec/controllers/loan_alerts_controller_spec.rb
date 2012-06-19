require 'spec_helper'

describe LoanAlertsController do

  let(:current_lender) { FactoryGirl.create(:lender) }

  let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

  before { sign_in(current_user) }

  describe "#not_drawn" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 180.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 170.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :offered, lender: current_lender, updated_at: 130.days.ago) }

    def dispatch(params = {})
      get :not_drawn, params
    end

    it_behaves_like "loan alerts controller"

  end

  describe "#not_demanded" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender, updated_at: 360.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender, updated_at: 350.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender, updated_at: 310.days.ago) }

    def dispatch(params = {})
      get :not_demanded, params
    end

    it_behaves_like "loan alerts controller"

  end

  describe "#not_progressed" do

    let!(:high_priority_loan) { FactoryGirl.create(:loan, :eligible, lender: current_lender, updated_at: 180.days.ago) }

    let!(:medium_priority_loan) { FactoryGirl.create(:loan, :completed, lender: current_lender, updated_at: 170.days.ago) }

    let!(:low_priority_loan) { FactoryGirl.create(:loan, :incomplete, lender: current_lender, updated_at: 130.days.ago) }

    def dispatch(params = {})
      get :not_progressed, params
    end

    it_behaves_like "loan alerts controller"

  end

end