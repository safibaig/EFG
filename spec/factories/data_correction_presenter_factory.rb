FactoryGirl.define do
  factory :data_correction_presenter do
    association :created_by, factory: :lender_user
    loan

    factory :sortcode_data_correction_presenter, class: SortcodeDataCorrectionPresenter do
      sortcode '123456'
    end
  end
end
