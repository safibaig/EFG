class LoanCategory < StaticAssociation
  self.data = [
    {
      id: 1,
      name: 'Type A - New Term Loan with No Security',
      min_loan_term: 3,
      max_loan_term: 120
    },
    {
      id: 2,
      name: 'Type B - New Term Loan with Partial Security',
      min_loan_term: 3,
      max_loan_term: 120
    },
    {
      id: 3,
      name: 'Type C - New Term Loan for Overdraft Refinancing',
      min_loan_term: 3,
      max_loan_term: 120
    },
    {
      id: 4,
      name: 'Type D - New Term Loan for Debt Consolidation or Refinancing',
      min_loan_term: 3,
      max_loan_term: 120
    },
    {
      id: 5,
      name: 'Type E - Overdraft Guarantee Facility',
      min_loan_term: 3,
      max_loan_term: 24
    },
    {
      id: 6,
      name: 'Type F - Invoice Finance Guarantee Facility',
      min_loan_term: 3,
      max_loan_term: 36
    }
  ]
end
