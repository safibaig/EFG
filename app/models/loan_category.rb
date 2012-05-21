class LoanCategory < StaticAssociation
  self.data = [
    { id: 1, name: 'Type A - New Term Loan with No Security' },
    { id: 2, name: 'Type B - New Term Loan with Partial Security' },
    { id: 3, name: 'Type C - New Term Loan for Overdraft Refinancing' },
    { id: 4, name: 'Type D - New Term Loan for Debt Consolidation or Refinancing' },
    { id: 5, name: 'Type E - Overdraft Guarantee Facility' },
    { id: 6, name: 'Type F - Invoice Finance Guarantee Facility' }
  ]
end
