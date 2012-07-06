require 'spec_helper'

describe LenderUserPermissions do
  include RefuteMacro
  include LenderUserPermissions

  context "invoices" do
    it "can't view" do
      refute can_view?(Invoice.new)
    end

    it "can't create" do
      refute can_create?(Invoice)
    end
  end

  context "loan eligibility checks" do
    it "can create" do
      assert can_create?(LoanEligibilityCheck)
    end
  end
end
