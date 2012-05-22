require 'spec_helper'

describe MemorablePassword do
  describe ".generate" do
    it "should generate a random password (using Haddock)" do
      Haddock::Password.stub(:generate).and_return('Password1')
      MemorablePassword.generate.should == 'Password1'
    end
  end
end
