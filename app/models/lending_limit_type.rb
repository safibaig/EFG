class LendingLimitType < StaticAssociation
  self.data = [
    { id: 1, name: 'Annual' },
    { id: 2, name: 'Specific' }
  ]

  Annual = find(1)
  Specific = find(2)
end
