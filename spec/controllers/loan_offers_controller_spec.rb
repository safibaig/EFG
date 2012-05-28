require 'spec_helper'

describe LoanOffersController do
  describe '#new' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
    before { sign_in(current_user) }

    def dispatch(params)
      get :new, params
    end

    it 'works with a loan from the same lender' do
      loan = FactoryGirl.create(:loan, :completed, lender: current_lender)

      dispatch loan_id: loan.id

      response.should be_success
    end

    it 'raises RecordNotFound for a loan from another lender' do
      other_lender = FactoryGirl.create(:lender)
      loan = FactoryGirl.create(:loan, :completed, lender: other_lender)

      expect {
        dispatch loan_id: loan.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#create' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }
    before { sign_in(current_user) }

    def dispatch(params)
      post :create, { loan_offer: {} }.merge(params)
    end

    it 'works with a loan from the same lender' do
      loan = FactoryGirl.create(:loan, :completed, lender: current_lender)

      dispatch loan_id: loan.id

      response.should be_redirect
    end

    it 'raises RecordNotFound for a loan from another lender' do
      other_lender = FactoryGirl.create(:lender)
      loan = FactoryGirl.create(:loan, :completed, lender: other_lender)

      expect {
        dispatch loan_id: loan.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
