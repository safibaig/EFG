require 'spec_helper'

describe Help::AskAnExpertController do
  describe '#new' do
    before { sign_in(current_user) }

    def dispatch
      get :new
    end

    [
      :auditor_user,
      :cfe_admin,
      :cfe_user,
      :expert_lender_admin,
      :expert_lender_user,
      :premium_collector_user
    ].each do |type|
      context "as a #{type}" do
        let(:current_user) { FactoryGirl.create(type) }

        it do
          expect {
            dispatch
          }.to raise_error(Canable::Transgression)
        end
      end
    end
  end

  describe '#create' do
    before { sign_in(current_user) }

    def dispatch
      post :create
    end

    [
      :auditor_user,
      :cfe_admin,
      :cfe_user,
      :expert_lender_admin,
      :expert_lender_user,
      :premium_collector_user
    ].each do |type|
      context "as a #{type}" do
        let(:current_user) { FactoryGirl.create(type) }

        it do
          expect {
            dispatch
          }.to raise_error(Canable::Transgression)
        end
      end
    end
  end
end
