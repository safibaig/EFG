require 'spec_helper'

describe UsersController do
  describe '#create' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) {
      FactoryGirl.create(:user, lender: current_lender)
    }

    before do
      sign_in current_user
    end

    def dispatch
      post :create, user: FactoryGirl.attributes_for(:user)
    end

    it 'assigns the newly created user to the current_lender' do
      expect {
        dispatch
      }.to change(User, :count).by(1)

      User.last.lender.should == current_lender
    end
  end

  describe '#show' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) {
      FactoryGirl.create(:user, lender: current_lender)
    }

    before do
      sign_in current_user
    end

    def dispatch(params)
      get :show, params
    end

    it 'works with a user from the same lender' do
      other_user = FactoryGirl.create(:user, lender: current_lender)

      dispatch id: other_user.id

      response.should be_success
    end

    it 'raises RecordNotFound for a user from another lender' do
      other_lender = FactoryGirl.create(:lender)
      other_user = FactoryGirl.create(:user, lender: other_lender)

      expect {
        dispatch id: other_user.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#edit' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) {
      FactoryGirl.create(:user, lender: current_lender)
    }

    before do
      sign_in current_user
    end

    def dispatch(params)
      get :edit, params
    end

    it 'works with a user from the same lender' do
      other_user = FactoryGirl.create(:user, lender: current_lender)

      dispatch id: other_user.id

      response.should be_success
    end

    it 'raises RecordNotFound for a user from another lender' do
      other_lender = FactoryGirl.create(:lender)
      other_user = FactoryGirl.create(:user, lender: other_lender)

      expect {
        dispatch id: other_user.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#update' do
    let(:current_lender) { FactoryGirl.create(:lender) }
    let(:current_user) {
      FactoryGirl.create(:user, lender: current_lender)
    }

    before do
      sign_in current_user
    end

    def dispatch(params)
      put :update, { user: {} }.merge(params)
    end

    it 'works with a user from the same lender' do
      other_user = FactoryGirl.create(:user, lender: current_lender)

      dispatch id: other_user.id

      response.should be_redirect
    end

    it 'raises RecordNotFound for a user from another lender' do
      other_lender = FactoryGirl.create(:lender)
      other_user = FactoryGirl.create(:user, lender: other_lender)

      expect {
        dispatch id: other_user.id
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
