require 'spec_helper'

describe RealiseLoansController do

  describe "GET show" do
    let(:realisation_statement) { FactoryGirl.create(:realisation_statement) }

    def dispatch
      get :show, id: realisation_statement.id
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "GET new" do
    def dispatch
      get :new
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe "POST select_loans" do
    def dispatch(params = {})
      post :select_loans, params
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'

    context 'when requesting CSV export' do
      let(:current_user) { FactoryGirl.create(:cfe_user) }
      let(:lender) { FactoryGirl.create(:lender) }

      before do
        sign_in(current_user)
        dispatch(
          realisation_statement: {
            lender_id: lender.id,
            reference: '1',
            period_covered_quarter: "June",
            period_covered_year: '2012',
            received_on: '20/05/2012'
          },
          format: 'csv'
        )
      end

      it "renders CSV loan data" do
        response.content_type.should == 'text/csv'
      end

      it "sets filename for CSV" do
        expected_filename = "loan_recoveries_#{lender.name.parameterize}_#{Date.today.strftime('%Y-%m-%d')}.csv"
        response.headers['Content-Disposition'].should include(%Q(filename="#{expected_filename}"))
      end
    end
  end

  describe "POST create" do
    def dispatch
      post :create
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'LenderAdmin-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

end
