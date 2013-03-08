require 'spec_helper'

describe User do
  it "migrates correct old-style passwords on sign-in" do
    password = ("4 l0nG sT!,ng " * 10)[0..127]
    old_encrypted_password = ::BCrypt::Password.create("#{password}", :cost => 10).to_s

    user = FactoryGirl.create(:user)
    user.update_column :encrypted_password, old_encrypted_password

    user.reload

    user.encrypted_password.should == old_encrypted_password

    user.valid_legacy_password?(password).should == true # We have a bcrypt hash saved
    user.valid_password?(password).should == true # We should update the password to the new hashing standard

    user.reload

    # valid_password? should have had the side-effect of updating the stored password hash.
    old_encrypted_password.should_not == user.encrypted_password
    user.valid_password?(password).should == true
  end

  it "does not migrate incorrect passwords" do
    password = ("4 l0nG sT!,ng " * 10)[0..127]
    old_encrypted_password = ::BCrypt::Password.create("#{password}", :cost => 10).to_s

    user = FactoryGirl.create(:user)
    user.update_column :encrypted_password, old_encrypted_password

    user.reload

    user.valid_password?("something else").should_not == true

    user.reload

    old_encrypted_password.should == user.encrypted_password # encrypted_password has not been changed
  end

  it "requires passwords to be suitably strong" do
    user = FactoryGirl.build(:user, :password => "aaaaaa")
    user.valid?.should == true
    user.save!

    # REVIEW: slightly hokey - we don't validate the password for new records. Not sure if we want to revisit that?
    user.first_name = user.last_name
    user.valid?.should == false
    user.errors[:password].should == [I18n.t('errors.messages.insufficient_entropy', entropy: 3, minimum_entropy: Devise::Models::Strengthened::MINIMUM_ENTROPY)]
  end
end