require 'spec_helper'

describe 'loan alerts' do
  let(:current_user) { FactoryGirl.create(:lender_user) }
  before { login_as(current_user, scope: :user) }

  describe '#show' do
    let!(:high_priority_efg_loan) {
      FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender, maturity_date: 3.months.ago)
    }

    context '.csv' do
      it 'responds with a CSV' do
        visit root_path
        find('#not_closed_loan_alerts a.view-all').click
        first(:link, 'Export CSV').click
        page.response_headers['Content-Type'].should include('text/csv')
      end
    end
  end
end
