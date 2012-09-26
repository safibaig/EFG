require 'spec_helper'

describe AskForHelpMailer do
  describe '#ask_an_expert' do
    let(:expert1) { FactoryGirl.build(:lender_admin, expert: true)}
    let(:expert2) { FactoryGirl.build(:lender_user, expert: true)}
    let(:user) { FactoryGirl.build(:lender_user) }
    let(:ask_an_expert) {
      AskAnExpert.new.tap { |ask_an_expert|
        ask_an_expert.experts = [expert1, expert2]
        ask_an_expert.message = 'Hello'
        ask_an_expert.user = user
      }
    }
    let(:email) { AskForHelpMailer.ask_an_expert_email(ask_an_expert) }

    it do
      email.body.should include(user.name)
      email.body.should include('Hello')
      email.from.should == [Devise.mailer_sender]
      email.reply_to.should == [user.email]
      email.to.should include(expert1.email)
      email.to.should include(expert2.email)
    end
  end

  describe '#ask_cfe' do
    let(:ask_cfe) {
      double.tap { |ask_cfe|
        ask_cfe.stub(:from).and_return('bill@example.com')
        ask_cfe.stub(:from_name).and_return('Bill S. Preston Esquire')
        ask_cfe.stub(:message).and_return('Excellent!')
        ask_cfe.stub(:to).and_return('ted@example.com')
      }
    }
    let(:email) { AskForHelpMailer.ask_cfe_email(ask_cfe) }

    it do
      email.body.should match(/Bill S. Preston Esquire/)
      email.body.should match(/Excellent!/)
      email.from.should == [Devise.mailer_sender]
      email.reply_to.should == ['bill@example.com']
      email.to.should == ['ted@example.com']
    end
  end
end
