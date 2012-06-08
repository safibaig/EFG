class CancelReason < StaticAssociation
  self.data = [
    { id: 1, name: 'Borrower does not require loan' },
    { id: 2, name: 'Lender credit rejected' },
    { id: 3, name: 'Alternative loan processed' },
    { id: 4, name: 'Other' }
  ]
end
