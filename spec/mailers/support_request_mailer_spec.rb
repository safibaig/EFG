require 'spec_helper'

describe SupportRequestMailer do

  describe "#notification_email" do
    before do
      @support_request = FactoryGirl.build(:support_request)
      @support_request.stub!(:recipients).and_return([ 'recipient1@example.com', 'recipient2@example.com'])

      @email = SupportRequestMailer.notification_email(@support_request, 'Chrome 11.0', 'Windows')
    end

    it "should have a to header" do
      @email.to.should == [ 'recipient1@example.com', 'recipient2@example.com']
    end

    it "should have a from header" do
      @email.from.should == [ Devise.mailer_sender ]
    end

    it "should have a reply-to header" do
      @email.reply_to.should == [ @support_request.user.email ]
    end

    it "should contain user's name" do
      @email.body.should match(/#{@support_request.user.name}/)
    end

    it "should contain the support request message" do
      @email.body.should match(/#{@support_request.message}/)
    end

    it "should contain the user's browser" do
      @email.body.should match(/Chrome 11.0/)
    end

    it "should contain the user's operating system" do
      @email.body.should match(/Windows/)
    end

    it "should contain a list of all recipients of the email" do
      @email.body.should match(/recipient1@example.com, recipient2@example.com/)
    end
  end

end
