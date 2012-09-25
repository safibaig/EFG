require 'spec_helper'

describe AskForHelpMailer do
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
