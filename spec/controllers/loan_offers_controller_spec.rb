require 'spec_helper'

describe LoanOffersController do
  let(:loan) { FactoryGirl.create(:loan, :completed) }

  describe '#new' do
    def dispatch(params = {})
      get :new, { loan_id: loan.id }.merge(params)
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

      it do
        dispatch
        response.should be_success
      end
    end
  end

  describe '#create' do
    def dispatch(params = {})
      post :create, { loan_id: loan.id, loan_offer: {} }.merge(params)
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
      let(:loan_offer) { double(LoanOffer, loan: loan, :attributes= => nil)}
      before { LoanOffer.stub!(:new).and_return(loan_offer) }

      context 'when submitting a valid loan' do
        before { loan_offer.stub!(:save).and_return(true) }

        def dispatch(parameters = {})
          super(commit: 'Submit')
        end

        it 'should redirect to the loan page' do
          dispatch
          response.should redirect_to(loan_url(loan))
        end
      end

      context 'when submitting an invalid loan' do
        before { loan_offer.stub!(:save).and_return(false) }

        def dispatch(parameters = {})
          super(commit: 'Submit')
        end

        it 'should render new action' do
          dispatch
          response.should render_template(:new)
        end
      end
    end
  end
end
