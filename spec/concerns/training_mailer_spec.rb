require 'spec_helper'

describe TrainingMailer do

  describe "inclusion into a mailer" do
    let(:mailer) do
      Class.new(ActionMailer::Base) do
        include TrainingMailer

        def test
          mail(subject: 'Test Mail')
        end
      end
    end

    it "should prepend [TRAINING] to the subject" do
      mailer.test.subject.should == '[TRAINING] Test Mail'
    end
  end

end
