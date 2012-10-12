require 'spec_helper'

describe AskForHelpMailer do
  describe '#ask_an_expert' do
    let(:expert_user1) { FactoryGirl.build(:expert_lender_admin) }
    let(:expert_user2) { FactoryGirl.build(:expert_lender_user) }
    let(:user) { FactoryGirl.build(:lender_user) }
    let(:ask_an_expert) {
      AskAnExpert.new.tap { |ask_an_expert|
        ask_an_expert.expert_users = [expert_user2, expert_user1]
        ask_an_expert.message = 'Hello'
        ask_an_expert.user = user
      }
    }
    let(:email) { AskForHelpMailer.ask_an_expert_email(ask_an_expert) }

    it do
      email.body.should include(user.name)
      email.body.should include('Hello')
      Devise.mailer_sender.should match email.from[0]
      email.reply_to.should == [user.email]
      email.subject.should include('EFG')
      email.to.should include(expert_user1.email)
      email.to.should include(expert_user2.email)
    end
  end

  describe '#ask_cfe' do
    let(:user) { FactoryGirl.build(:lender_user) }
    let(:ask_cfe) {
      AskCfe.new.tap { |ask_an_expert|
        ask_an_expert.message = 'Excellent!'
        ask_an_expert.user = user
        ask_an_expert.user_agent = OpenStruct.new(
          browser: 'Lynx',
          os: 'ABC',
          platform: 'Foo',
          version: '1.2.3'
        )
      }
    }
    let(:email) { AskForHelpMailer.ask_cfe_email(ask_cfe) }

    it do
      email.body.should include(user.name)
      email.body.should include('Excellent!')
      email.body.should include('Lynx, 1.2.3')
      email.body.should include('Foo, ABC')
      Devise.mailer_sender.should match email.from[0]
      email.reply_to.should == [user.email]
      email.subject.should include('EFG')
      email.to.should == [ EFG::Application.config.cfe_support_email ]
    end
  end
end
