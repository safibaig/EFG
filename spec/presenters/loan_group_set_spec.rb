# encoding: utf-8

require 'spec_helper'

describe LoanGroupSet do
  describe "groups" do
    let(:group_set) { LoanGroupSet.new }

    it "should have the correct groups" do
      FactoryGirl.create(:phase, name: 'Phase 1')
      FactoryGirl.create(:phase, name: 'Phase 2')

      group_names = group_set.groups.map(&:name).to_a
      group_names.should == ['Legacy SFLG Loans', 'SFLG Loans', 'EFG Loans – Phase 1', 'EFG Loans – Phase 2', 'EFG Loans – Unknown Phase']
    end

    it "should respond to loans" do
      group_set.groups.each do |group|
        group.should respond_to(:loans)
      end
    end
  end
end
