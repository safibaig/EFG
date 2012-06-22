require 'spec_helper'

describe DocumentsController do

  describe '#state_aid_letter' do
    let(:current_lender) { FactoryGirl.create(:lender) }

    let(:current_user) { FactoryGirl.create(:user, lender: current_lender) }

    let(:loan) { FactoryGirl.create(:loan, :lender_demand, lender: current_lender) }

    before { sign_in(current_user) }

    def dispatch(params)
      get :state_aid_letter, params
    end

    it 'works with a loan from the same lender' do
      dispatch id: loan.id

      response.should be_success
    end

    it 'raises RecordNotFound for a loan from another lender' do
      other_lender = FactoryGirl.create(:lender)
      loan = FactoryGirl.create(:loan, :lender_demand, lender: other_lender)

      expect {
        dispatch id: loan.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'renders PDF document' do
      dispatch id: loan.id

      response.content_type.should == 'application/pdf'
    end
  end


end
