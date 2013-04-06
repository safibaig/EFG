FactoryGirl.define do
  factory :data_correction_presenter do
    ignore do
      association :loan, factory: [:loan, :guaranteed]
    end

    association :created_by, factory: :lender_user

    initialize_with do
      new(loan)
    end

    factory :business_name_data_correction, class: BusinessNameDataCorrection do
      business_name 'New Business Name'
    end

    factory :demanded_amount_data_correction, class: DemandedAmountDataCorrection do
      demanded_amount Money.new(1_000_00)
      association :loan, factory: [:loan, :guaranteed, :demanded]
    end

    factory :sortcode_data_correction, class: SortcodeDataCorrection do
      sortcode '123456'
    end
  end
end
