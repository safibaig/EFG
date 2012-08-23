shared_examples_for 'User' do
  describe 'validations' do
    it 'should have a valid factory' do
      user.should be_valid
    end

    it 'should require a first_name' do
      user.first_name = ''
      user.should_not be_valid
    end

    it 'should require a last_name' do
      user.last_name = ''
      user.should_not be_valid
    end

    it 'should not require a password when a new record' do
      user.password = nil
      user.password_confirmation = nil
      user.encrypted_password = nil

      user.should be_valid
    end

    it 'should require a password when being set on an existing user' do
      user.save!
      user.password = 'newpassword'
      user.password_confirmation = ''

      user.should_not be_valid
    end

    it 'should not require a unique email address' do
      user.save!
      another_user = FactoryGirl.build(user.class.to_s.underscore, email: user.email)

      another_user.should be_valid
    end
  end

  describe "#has_password?" do
    it 'should return false when encrypted_password is blank' do
      user.encrypted_password = nil
      user.should_not have_password
    end

    it 'should return true when encrypted_password is present' do
      user.encrypted_password = 'abc123'
      user.should have_password
    end
  end

  describe "#password_reset_pending?" do
    it "should return false when user has no password reset token" do
      user.reset_password_token = nil
      user.password_reset_pending?.should == false
    end

    it "should return false when user has expired password reset token" do
      user.reset_password_token = 'abc123'
      user.reset_password_sent_at = 1.month.ago
      user.password_reset_pending?.should == false
    end

    it "should return true when user has password reset token that has not expired" do
      user.reset_password_token = 'abc123'
      user.reset_password_sent_at = 1.minute.ago
      user.password_reset_pending?.should == true
    end
  end

  describe '#send_new_account_notification' do
    before(:each) do
      user.save!
      ActionMailer::Base.deliveries.clear
    end

    it "should set reset_password_token" do
      user.reset_password_token.should be_nil
      user.send_new_account_notification
      user.reset_password_token.should_not be_nil
    end

    it "should set reset_password_sent_at" do
      user.reset_password_sent_at.should be_nil
      user.send_new_account_notification
      user.reset_password_sent_at.should_not be_nil
    end

    it "should send email to user" do
      user.send_new_account_notification

      emails = ActionMailer::Base.deliveries
      emails.size.should == 1
      emails.first.to.should == [ user.email ]
    end
  end

  describe "#username" do
    it "should be set when user is created" do
      user.username.should be_blank
      user.save!
      user.username.should_not be_blank
    end

    it "should be lowercase" do
      user.save!
      user.username[0,4].should_not match(/[A-Z]/)
      user.username[-1,1].should_not match(/[A-Z]/)
    end
  end

  describe "#reset_failed_attempts callback" do
    it 'should set failed_attempts to 0 when user is unlocked' do
      user.locked = true
      user.failed_attempts = 3
      user.save

      user.failed_attempts.should == 3
      user.locked = false
      user.save

      user.failed_attempts.should == 0
    end

    it 'should not change failed_attempts when user is not unlocked' do
      user.locked = true
      user.failed_attempts = 3
      user.save

      user.locked = true
      user.save

      user.failed_attempts.should == 3
    end
  end
end
