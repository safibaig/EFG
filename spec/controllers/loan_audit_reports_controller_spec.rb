require 'spec_helper'

shared_examples_for 'loan audit report controller action' do
  context 'with auditor user' do
    let(:current_user) { FactoryGirl.create(:auditor_user) }

    before { sign_in(current_user) }

    it "should allow access" do
      dispatch
      response.should be_success
    end
  end

  context 'with cfe user' do
    let(:current_user) { FactoryGirl.create(:cfe_user) }

    before { sign_in(current_user) }

    it "should allow access" do
      dispatch
      response.should be_success
    end
  end

  context 'when not an auditor or cfe user' do
    let(:current_user) { FactoryGirl.create(:premium_collector_user) }

    before { sign_in(current_user) }

    it "should not allow access" do
      expect {
        dispatch
      }.to raise_error(Canable::Transgression)
    end
  end
end

describe LoanAuditReportsController do

  describe "#new" do
    def dispatch
      get :new
    end

    it_should_behave_like 'loan audit report controller action'
  end

  describe "#create" do
    def dispatch(params = {})
      post :create, loan_audit_report: params
    end

    it_should_behave_like 'loan audit report controller action'
  end

end
