require 'spec_helper'

describe LoanEligibilityDecisionsController do

  describe "#show" do

    let(:loan) { FactoryGirl.create(:loan) }

    def dispatch(params = {})
      get :show, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user) }

      before { sign_in(current_user) }

      context 'with eligible loan' do
        let(:loan) { FactoryGirl.create(:loan, :eligible, lender: current_user.lender) }

        it "should render" do
          dispatch
          response.should be_success
        end
      end

      context 'with ineligible loan' do
        let(:loan) { FactoryGirl.create(:loan, :rejected, lender: current_user.lender) }

        it "should render" do
          dispatch
          response.should be_success
        end
      end

      context 'with offered loan' do
        let(:loan) { FactoryGirl.create(:loan, :offered, lender: current_user.lender) }

        it "should raise exception" do
          expect {
            dispatch
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

  end

end
