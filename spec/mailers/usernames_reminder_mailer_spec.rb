require 'spec_helper'

describe UsernamesReminderMailer do
  let(:mailer) {
    UsernamesReminderMailer.usernames_reminder('me@example.com', %w(user1 user2))
  }

  describe '#usernames_reminder' do
    it 'has the correct to email address' do
      mailer.to.should == ['me@example.com']
    end

    it 'contains the usernames specified' do
      mailer.body.should include('user1')
      mailer.body.should include('user2')
    end

    it 'has the correct from email address' do
      Devise.mailer_sender.should match mailer.from[0]
    end
  end
end
