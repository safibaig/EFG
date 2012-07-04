require 'spec_helper'

describe LoanNoClaimsController do
  describe '#new' do
    let(:loan) { FactoryGirl.create(:loan, :lender_demand) }

    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#create' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
    before { sign_in(current_user) }

    def dispatch(params = {})
      default_params = { loan_id: loan.id, loan_no_claim: {} }
      post :create, default_params.merge(params)
    end

    context "with another lender's loan" do
      let(:other_lender) { FactoryGirl.create(:lender) }
      let(:loan) { FactoryGirl.create(:loan, :lender_demand, lender: other_lender) }

      it 'raises RecordNotFound for a loan from another lender' do
        expect {
          dispatch
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
