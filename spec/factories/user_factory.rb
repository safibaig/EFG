FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "Joe#{n}" }
    last_name 'Bloggs'
    sequence(:email) { |n| "joe#{n}@example.com" }
    password 'a suitably str0ng passw0rd. w1bbl3'

    factory :auditor_user, class: AuditorUser
    factory :cfe_admin, class: CfeAdmin
    factory :cfe_user, class: CfeUser
    factory :super_user, class: SuperUser

    factory :lender_admin, class: LenderAdmin do
      lender
    end

    factory :lender_user, class: LenderUser do
      lender
    end

    factory :premium_collector_user, class: PremiumCollectorUser

    factory :system_user, class: SystemUser do
      id -1
      username 'system'
    end

    expertable = Proc.new {
      after :create do |user|
        FactoryGirl.create(:expert, user: user)
      end
    }

    factory :expert_lender_admin, parent: :lender_admin, &expertable
    factory :expert_lender_user, parent: :lender_user, &expertable
  end
end
