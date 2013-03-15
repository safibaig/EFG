class LoanCategory < StaticAssociation
  self.data = [
    {
      id: 1,
      name: 'Type A - New Term Loan with No Security',
      min_repayment_duration: 3,
      max_repayment_duration: 120
    },
    {
      id: 2,
      name: 'Type B - New Term Loan with Partial Security',
      min_repayment_duration: 3,
      max_repayment_duration: 120
    },
    {
      id: 3,
      name: 'Type C - New Term Loan for Overdraft Refinancing',
      min_repayment_duration: 3,
      max_repayment_duration: 120
    },
    {
      id: 4,
      name: 'Type D - New Term Loan for Debt Consolidation or Refinancing',
      min_repayment_duration: 3,
      max_repayment_duration: 120
    },
    {
      id: 5,
      name: 'Type E - Overdraft Guarantee Facility',
      min_repayment_duration: 3,
      max_repayment_duration: 24
    },
    {
      id: 6,
      name: 'Type F - Invoice Finance Guarantee Facility',
      min_repayment_duration: 3,
      max_repayment_duration: 36
    }
  ]
end
