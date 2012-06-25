require 'spec_helper'

describe SearchController do

  describe '#show' do

    let(:current_lender) { FactoryGirl.create(:lender) }

    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

    let!(:loan) { FactoryGirl.create(:loan, reference: "ABC123", lender: current_lender)}

    before { sign_in(current_user) }

    def dispatch(params)
      get :show, params
    end

    it 'returns loans for the current lender' do
      dispatch reference: loan.reference

      assigns[:loans].should include(loan)
    end

    it 'does not return loans from another lender' do
      other_lender      = FactoryGirl.create(:lender)
      other_lender_loan = FactoryGirl.create(:loan, reference: "ABC123", lender: other_lender)

      dispatch reference: other_lender_loan.reference

      assigns[:loans].should_not include(other_lender_loan)
    end
  end

end
