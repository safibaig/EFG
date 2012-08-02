require 'spec_helper'

describe LoanReportsController do

  let(:loan) { FactoryGirl.create(:loan, :eligible) }

  describe "#create" do

    def dispatch(params = {})
      post :create, loan_report: params
    end

    context 'with lender user' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }

      let(:loan2) { FactoryGirl.create(:loan, :eligible) }

      before { sign_in(current_user) }

      it "should raise exception when trying to access loans belonging to a different lender" do
        expect {
          dispatch(lender_ids: [ loan.lender.id, loan2.lender.id ])
        }.to raise_error(LoanReport::LenderNotAllowed)
      end
    end

  end

end
