ActiveRecord::Base.transaction do
  {
    '47800' => 'Stall Sales',
    '52100' => 'Operation of warehousing & storage facilities',
    '52240' => 'Cargo Handling',
    '53200' => 'Courier activities'
  }.each do |(code, desc)|
    unless SicCode.exists?(code: code)
      SicCode.create!(code: code, description: desc, eligible: false, public_sector_restricted: false, active: false)
    end
  end
end
