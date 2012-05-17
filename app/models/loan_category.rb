class LoanCategory < Struct.new(:id, :name)
  def self.all
    @all ||= [
      new(1, 'Type A - New Term Loan with No Security'),
      new(2, 'Type B - New Term Loan with Partial Security'),
      new(3, 'Type C - New Term Loan for Overdraft Refinancing'),
      new(4, 'Type D - New Term Loan for Debt Consolidation or Refinancing'),
      new(5, 'Type E - Overdraft Guarantee Facility'),
      new(6, 'Type F - Invoice Finance Guarantee Facility')
    ]
  end
end
