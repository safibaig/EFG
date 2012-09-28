require 'spec_helper'

describe Help::AskCfeController do
  describe '#new' do
    before { sign_in(current_user) }

    def dispatch
      get :new
    end

    [
      :lender_admin,
      :lender_user
    ].each do |type|
      context "as a non-expert #{type}" do
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
      :lender_admin,
      :lender_user
    ].each do |type|
      context "as a non-expert #{type}" do
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
