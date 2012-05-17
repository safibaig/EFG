require 'active_model/model'

class LoanEligibilityCheck
  include ActiveModel::Model

  LoanCategories = [
    'Type A - New Term Loan with No Security',
    'Type B - New Term Loan with Partial Security',
    'Type C - New Term Loan for Overdraft Refinancing',
    'Type D - New Term Loan for Debt Consolidation or Refinancing',
    'Type E - Overdraft Guarantee Facility',
    'Type F - Invoice Finance Guarantee Facility'
  ]

  LoanFacilities = [
    'EFG Training'
  ]

  LoanReasons = [
    'Start-up costs',
    'General working capital requirements',
    'Purchasing specific equipment or machinery',
    'Purchasing licences, quotas or other entitlements to trade',
    'Research and Development activities',
    'Acquiring another business within UK',
    'Acquiring another business outside UK',
    'Expanding an existing business within UK',
    'Expanding an existing business outside UK',
    'Replacing existing finance',
    'Financing an export order'
  ]

  attr_accessor :viable_proposition, :would_you_lend, :collateral_exhausted,
                :amount, :lender_cap, :repayment_duration, :turnover,
                :trading_date, :sic_code, :loan_category, :reason,
                :previous_borrowing, :private_residence_charge_required,
                :personal_guarantee_required
end
