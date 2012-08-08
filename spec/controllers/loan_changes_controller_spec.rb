require 'spec_helper'

describe LoanChangesController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#index' do
    def dispatch(params = {})
      get :index, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'LenderUser-restricted LoanPresenter controller'
  end

  describe '#show' do
    let(:loan_change) { FactoryGirl.create(:loan_change, loan: loan) }

    def dispatch(params = {})
      get :show, { id: loan_change.id, loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'LenderUser-restricted LoanPresenter controller'
  end

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      [Loan::Guaranteed, Loan::LenderDemand].each do |state|
        context "for a loan in state #{state}" do
          before do
            loan.update_attribute :state, state
          end

          it do
            dispatch
            response.should be_success
          end
        end
      end

      context 'for a loan in an invalid state' do
        before do
          loan.update_attribute :state, Loan::Eligible
        end

        it do
          expect {
            dispatch
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, loan_change: { business_name: 'acme' } }.merge(params)
    end

    it_behaves_like 'CfeUser-restricted LoanPresenter controller'
    it_behaves_like 'LenderUser-restricted LoanPresenter controller'

    context 'when logged in' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      context 'and regenerating schedule' do
        it 'should redirect to regenerate schedule controller with loan changes in params' do
          dispatch(commit: 'Reschedule')
          response.should redirect_to(new_loan_regenerate_schedule_path(loan_change: { business_name: 'acme' }))
        end
      end
    end
  end

end