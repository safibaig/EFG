require 'spec_helper'

describe CfeUserPermissions do
  include RefuteMacro
  include CfeUserPermissions

  context "invoices" do
    it "can view" do
      assert can_view?(Invoice.new)
    end

    it "can create" do
      assert can_create?(Invoice)
    end
  end

  context "loan eligibility checks" do
    it "can't create" do
      refute can_create?(LoanEligibilityCheck)
    end
  end
end
