class LoanEvent < StaticAssociation
  self.data = [
    {id: 0, name: 'Reject'},
    {id: 1, name: 'Accept'},
    {id: 2, name: 'Loan entry'},
    {id: 3, name: 'Cancel loan'},
    {id: 4, name: 'Complete'},
    {id: 5, name: 'Offer scheme facility'},
    {id: 6, name: 'Not progressed'},
    {id: 7, name: 'Guarantee and initial draw'},
    {id: 8, name: 'Not drawn'},
    {id: 9, name: 'Change amount or terms'},
    {id: 10, name: 'Demand to borrower'},
    {id: 11, name: 'Not demanded'},
    {id: 12, name: 'No claim'},
    {id: 13, name: 'Demand against government guarantee'},
    {id: 14, name: 'Loan repaid'},
    {id: 15, name: 'Remove guarantee'},
    {id: 16, name: 'Transfer'},
    {id: 17, name: 'Not closed'},
    {id: 18, name: 'Create claim'},
    {id: 19, name: 'Realise money'},
    {id: 20, name: 'Recovery made'},
    {id: 21, name: 'Legacy loan imported'},
    {id: 22, name: 'Data correction'},
    {id: 23, name: 'Transfer (legacy)'},
    {id: 24, name: 'Data cleanup'}
  ]

  Reject = find(0)
  Accept = find(1)
  LoanEntry = find(2)
  Cancel = find(3)
  Complete = find(4)
  OfferSchemeFacility = find(5)
  NotProgressed = find(6)
  Guaranteed = find(7)
  NotDrawn = find(8)
  ChangeAmountOrTerms = find(9)
  DemandToBorrower = find(10)
  NotDemanded = find(11)
  NoClaim = find(12)
  DemandAgainstGovernmentGuarantee = find(13)
  LoanRepaid = find(14)
  RemoveGuarantee = find(15)
  Transfer = find(16)
  NotClosed = find(17)
  CreateClaim = find(18)
  RealiseMoney = find(19)
  RecoveryMade = find(20)
  LegacyLoanImported = find(21)
  DataCorrection = find(22)
  TransferLegacy = find(23)
  DataCleanup = find(24)

  def self.ids
    all.map(&:id)
  end
end
