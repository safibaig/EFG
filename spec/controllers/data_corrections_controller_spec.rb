require 'spec_helper'

describe DataCorrectionsController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#index' do
    def dispatch
      get :index, loan_id: loan.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id, type: 'sortcode' }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'as a LenderUser from the same lender' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }
      before { sign_in(current_user) }

      [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded].each do |state|
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

      context 'with an invalid type parameter' do
        it 'redirects to index' do
          dispatch type: 'foo'
          response.should redirect_to(loan_data_corrections_url)
        end
      end
    end
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, data_correction: {} }.merge(params)
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser Lender-scoped controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end
end
