class RepaymentFrequency < StaticAssociation
  self.data = [
    {id: 1, name: 'Annually'},
    {id: 2, name: 'Six Monthly'},
    {id: 3, name: 'Quarterly'},
    {id: 4, name: 'Monthly'},
    {id: 5, name: 'Interest Only - Single Repayment on Maturity'}
  ]
end
