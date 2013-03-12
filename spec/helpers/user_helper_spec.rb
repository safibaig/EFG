require 'spec_helper'

describe UserHelper do
  describe '#polymorphic_user_path' do
    context 'when the user is a type that belongs to a lender' do
      let(:lender) { FactoryGirl.build_stubbed(:lender) }
      let(:user)   { FactoryGirl.build_stubbed(:lender_user, lender: lender) }

      context 'and no action is specified' do
        it 'returns the correct path' do
          polymorphic_user_path(user).should == "/lenders/#{lender.id}/lender_users/#{user.id}"
        end
      end

      context 'and an action is specified' do
        it 'returns the correct path' do
          polymorphic_user_path(user, :edit).should == "/lenders/#{lender.id}/lender_users/#{user.id}/edit"
        end
      end
    end

    context 'when the user is not a type that belongs to a lender' do
      let(:user) { FactoryGirl.build_stubbed(:cfe_user) }

      context 'and no action is specified' do
        it 'returns the correct path' do
          polymorphic_user_path(user).should == "/cfe_users/#{user.id}"
        end
      end

      context 'and an action is specified' do
        it 'returns the correct path' do
          polymorphic_user_path(user, :edit).should == "/cfe_users/#{user.id}/edit"
        end
      end
    end
  end
end
