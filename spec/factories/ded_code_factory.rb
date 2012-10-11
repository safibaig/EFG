FactoryGirl.define do
  factory :ded_code do
    group_description 'Trading'
    category_description 'Loss of Market'
    sequence(:code) { |n| "A.10.1#{num}" }
    code_description 'Competition'
  end
end
