class LoanReason < StaticAssociation
  self.data = [
    { id: 1, name: 'Start-up costs' },
    { id: 2, name: 'General working capital requirements' },
    { id: 3, name: 'Purchasing specific equipment or machinery' },
    { id: 4, name: 'Purchasing licences, quotas or other entitlements to trade' },
    { id: 5, name: 'Research and Development activities' },
    { id: 6, name: 'Acquiring another business within UK' },
    { id: 7, name: 'Acquiring another business outside UK' },
    { id: 8, name: 'Expanding an existing business within UK' },
    { id: 9, name: 'Expanding an existing business outside UK' },
    { id: 10, name: 'Replacing existing finance' },
    { id: 11, name: 'Financing an export order' }
  ]
end
