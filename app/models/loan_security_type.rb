class LoanSecurityType < StaticAssociation
  self.data = [
    {id: 1, name: 'Residential property other than a principal private residence'},
    {id: 2, name: 'Commercial property'},
    {id: 3, name: 'Shares and other securities'},
    {id: 4, name: 'Cash on deposit'},
    {id: 5, name: 'Plant, machinery or other business equipment'},
    {id: 6, name: 'Raw materials or stock'},
    {id: 7, name: 'Personal vehicle, boat or other asset'},
    {id: 8, name: 'Personal life insurance or other policy'},
    {id: 9, name: 'Debenture or Floating Charge'},
    {id: 10, name: 'Other'}
  ]
end
