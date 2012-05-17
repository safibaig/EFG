class LoanReason < Struct.new(:id, :name)
  def self.all
    @all ||= [
      new(1, 'Start-up costs'),
      new(2, 'General working capital requirements'),
      new(3, 'Purchasing specific equipment or machinery'),
      new(4, 'Purchasing licences, quotas or other entitlements to trade'),
      new(5, 'Research and Development activities'),
      new(6, 'Acquiring another business within UK'),
      new(7, 'Acquiring another business outside UK'),
      new(8, 'Expanding an existing business within UK'),
      new(9, 'Expanding an existing business outside UK'),
      new(10, 'Replacing existing finance'),
      new(11, 'Financing an export order')
    ]
  end
end
