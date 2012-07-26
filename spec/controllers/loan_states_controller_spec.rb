require 'spec_helper'

describe LoanStatesController do
  let(:loan) { FactoryGirl.create(:loan, :guaranteed) }

  describe '#show' do
    def dispatch(params = {})
      get :show, { id: 'guaranteed' }.merge(params)
    end

    context 'when requesting CSV export' do
      let(:current_user) { FactoryGirl.create(:lender_user, lender: loan.lender) }

      before do
        sign_in(current_user)
        dispatch(format: 'csv')
      end

      it "renders CSV loan data" do
        response.content_type.should == 'text/csv'
      end

      it "sets filename for CSV" do
        expected_filename = "#{loan.state}_loans_#{Date.today.strftime('%Y-%m-%d')}.csv"
        response.headers['Content-Disposition'].should match(/filename="#{expected_filename}"/)
      end
    end

  end
end
