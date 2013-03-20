class RepaymentFrequency < StaticAssociation
  self.data = [
    {
      id: 1,
      name: 'Annually',
      premium_calculation_strategy: 'annually'
    },
    {
      id: 2,
      name: 'Six Monthly',
      premium_calculation_strategy: 'six_monthly'
    },
    {
      id: 3,
      name: 'Quarterly',
      premium_calculation_strategy: 'quarterly'
    },
    {
      id: 4,
      name: 'Monthly',
      premium_calculation_strategy: 'monthly'
    },
    {
      id: 5,
      name: 'Interest Only - Single Repayment on Maturity',
      premium_calculation_strategy: 'interest_only'
    }
  ]

  Annually = find(1)
  SixMonthly = find(2)
  Quarterly = find(3)
  Monthly = find(4)
  InterestOnly = find(5)
end
