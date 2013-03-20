class RepaymentFrequency < StaticAssociation
  self.data = [
    {
      id: 1,
      name: 'Annually',
      premium_calculation_strategy: 'annually',
      months_per_repayment_period: 12
    },
    {
      id: 2,
      name: 'Six Monthly',
      premium_calculation_strategy: 'six_monthly',
      months_per_repayment_period: 6
    },
    {
      id: 3,
      name: 'Quarterly',
      premium_calculation_strategy: 'quarterly',
      months_per_repayment_period: 3
    },
    {
      id: 4,
      name: 'Monthly',
      premium_calculation_strategy: 'monthly',
      months_per_repayment_period: 1
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
