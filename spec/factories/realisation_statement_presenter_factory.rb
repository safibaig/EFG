FactoryGirl.define do
  factory :realisation_statement_presenter do
    initialize_with {
      realisation_statement = FactoryGirl.build(:realisation_statement)
      new(realisation_statement)
    }
  end
end