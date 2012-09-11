FactoryGirl.define do
  factory :initial_draw_change do
    loan
    created_by factory: :user
    amount_drawn Money.new(10_000_00)
    date_of_change { Date.current }
    modified_date { Date.current }
  end
end
