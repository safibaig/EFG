require 'spec_helper'

describe LoansController do

  %w(show details audit_log).each do |action_name|

    describe "##{action_name}" do
      let(:loan) { FactoryGirl.create(:loan) }

      let(:action) { action_name }

      def dispatch(params = {})
        get action, { id: loan.id }.merge(params)
      end

      it_behaves_like 'CfeAdmin-restricted controller'
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

  end

end
