class LoanFacility < Struct.new(:id, :name)
  def self.all
    @all ||= [
      new(1, 'EFG Training')
    ]
  end
end
