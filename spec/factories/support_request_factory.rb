FactoryGirl.define do
  factory :support_request do
    user { FactoryGirl.build(:lender_user) }
    message "Help!"
  end
end