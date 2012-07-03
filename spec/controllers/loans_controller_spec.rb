require 'spec_helper'

describe LoansController do
  describe '#show' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) {
      FactoryGirl.create(:lender_user, lender: current_lender)
    }

    before do
      sign_in current_user
    end

    def dispatch(params)
      get :show, params
    end

    it 'works with a loan from the same lender' do
      loan = FactoryGirl.create(:loan, lender: current_lender)

      dispatch id: loan.id

      response.should be_success
    end

    it 'raises RecordNotFound for a loan from another lender' do
      other_lender = FactoryGirl.create(:lender)
      loan = FactoryGirl.create(:loan, lender: other_lender)

      expect {
        dispatch id: loan.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
