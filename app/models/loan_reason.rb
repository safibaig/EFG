class LoanReason < StaticAssociation
  self.data = [
    { id: 0 , name: "Replacing existing finance (original)", active: false },
    { id: 1, name: "Buying a business", active: false },
    { id: 2, name: "Buying a business overseas", active: false },
    { id: 3, name: "Developing a project", active: false },
    { id: 4, name: "Expanding an existing business", active: false },
    { id: 5, name: "Expanding a UK business abroad", active: false },
    { id: 6, name: "Export", active: false },
    { id: 7, name: "Improving vessels (health and safety)", active: false },
    { id: 8, name: "Increasing size and power of vessels", active: false },
    { id: 9, name: "Improving vessels (refrigeration)", active: false },
    { id: 10, name: "Improving efficiency", active: false },
    { id: 11, name: "Agricultural holdings investments", active: false },
    { id: 12, name: "Boat modernisation (over 5 years)", active: false },
    { id: 13, name: "Production, processing and marketing", active: false },
    { id: 14, name: "Property purchase/lease", active: false },
    { id: 15, name: "Agricultural holdings purchase", active: false },
    { id: 16, name: "Animal purchase", active: false },
    { id: 17, name: "Equipment purchase", active: false },
    { id: 18, name: "Purchasing fishing gear", active: false },
    { id: 19, name: "Purchasing fishing licences", active: false },
    { id: 20, name: "Purchasing fishing quotas", active: false },
    { id: 21, name: "Purchasing fishing rights", active: false },
    { id: 22, name: "Land purchase", active: false },
    { id: 23, name: "Purchasing quotas", active: false },
    { id: 24, name: "Vessel purchase", active: false },
    { id: 25, name: "Research and development", active: false },
    { id: 26, name: "Starting-up trading", active: false },
    { id: 27, name: "Working capital", active: false },
    { id: 28, name: 'Start-up costs', active: true },
    { id: 29, name: 'General working capital requirements', active: true },
    { id: 30, name: 'Purchasing specific equipment or machinery', active: true },
    { id: 31, name: 'Purchasing licences, quotas or other entitlements to trade', active: true },
    { id: 32, name: 'Research and Development activities', active: true },
    { id: 33, name: 'Acquiring another business within UK', active: true },
    { id: 34, name: 'Acquiring another business outside UK', active: true },
    { id: 35, name: 'Expanding an existing business within UK', active: true },
    { id: 36, name: 'Expanding an existing business outside UK', active: true },
    { id: 37, name: 'Replacing existing finance', active: true },
    { id: 38, name: 'Financing an export order', active: true }
  ].sort_by {|data| data[:name] }

  def self.active
    find_all_by_active(true)
  end
end
