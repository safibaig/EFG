class RepaymentFrequency < StaticAssociation
  self.data = [
    {id: 1, name: 'Annually'},
    {id: 2, name: 'Six Monthly'},
    {id: 3, name: 'Quarterly'},
    {id: 4, name: 'Monthly'},
    {id: 5, name: 'Interest Only - Single Repayment on Maturity'}
  ]

  Annually = find(1)
  SixMonthly = find(2)
  Quarterly = find(3)
  Monthly = find(4)
  InterestOnly = find(5)
end
