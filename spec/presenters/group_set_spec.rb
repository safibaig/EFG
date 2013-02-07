require 'spec_helper'

describe GroupSet do

  describe "#add" do
    let(:group_set) { GroupSet.new }

    it "adds a group" do
      group_set.add('SFLG Loans') {|loan| loan.success? }
      group_set.add('EFG Loans') {|loan| loan.success? }

      group_names = []
      group_set.each do |group|
        group_names << group.name
      end

      group_names.should == ['SFLG Loans', 'EFG Loans']
    end
  end

  describe "#filter" do
    let(:group_set) { GroupSet.new }
    let(:legacy_loan_1) { double(:legacy_loan? => true, :sflg? => false, :efg_loan? => false)}
    let(:legacy_loan_2) { double(:legacy_loan? => true, :sflg? => false, :efg_loan? => false)}
    let(:sflg_loan_1) { double(:legacy_loan? => false, :sflg? => true, :efg_loan? => false)}
    let(:sflg_loan_2) { double(:legacy_loan? => false, :sflg? => true, :efg_loan? => false)}
    let(:efg_loan_1) { double(:legacy_loan? => false, :sflg? => false, :efg_loan? => true)}
    let(:efg_loan_2) { double(:legacy_loan? => false, :sflg? => false, :efg_loan? => true)}

    before do
      group_set.add('Legacy SFLG Loans') {|loan| loan.legacy_loan? }
      group_set.add('SFLG Loans') {|loan| loan.sflg? }
      group_set.add('EFG Loans') {|loan| loan.efg_loan? }
    end

    it "filters the loans info the appropriate groups" do
      loans = [legacy_loan_1, legacy_loan_2, sflg_loan_1, sflg_loan_2, efg_loan_1, efg_loan_2]
      group_set.filter(loans)

      groups = group_set.to_a
      groups[0].objects.should =~ [legacy_loan_1, legacy_loan_2]
      groups[1].objects.should =~ [sflg_loan_1, sflg_loan_2]
      groups[2].objects.should =~ [efg_loan_1, efg_loan_2]
    end

    it "only filters objects into the first matching group" do
      group_set.add('Second Legacy Loans Group') {|loan| loan.legacy_loan? }
      group_set.filter([legacy_loan_1])

      groups = group_set.to_a
      groups[0].objects.should == [legacy_loan_1]
      groups[3].objects.should == []
    end
  end

end
