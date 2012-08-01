require 'spec_helper'

describe LoanReportsController do

  let(:loan) { FactoryGirl.create(:loan, :eligible) }

  describe "#create" do

    context 'with lender user' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }

      let(:loan2) { FactoryGirl.create(:loan, :eligible) }

      before { sign_in(current_user) }

      def dispatch
        post :create, loan_report: { lender_ids: [ loan.lender.id, loan2.lender.id ] }
      end

      it "should remove any lender IDs from params that the current user does not have access to" do
        LoanReport.
          should_receive(:new).
          with({ "lender_ids" => [ loan.lender.id.to_s ] }).
          and_return(mock(valid?: false))

        dispatch
      end
    end

  end

end
