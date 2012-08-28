require 'spec_helper'
require 'ithc/generator'

describe "Generator.seed " do
  def seed
    Ithc::Generator.seed("user.name@example.com")
  end

  describe "with existing lenders and loans" do
    it "should create a new CfeAdmin" do
      assert seed["CfeAdmin"][:created], "CfeAdmin was created"
    end

    it "should create a new CfeUser" do
      assert seed["CfeUser"][:created], "CfeUser was created"
    end

    it "should create a new PremiumCollectorUser" do
      assert seed["PremiumCollectorUser"][:created], "PremiumCollectorUser was created"
    end

    it "should create a new AuditorUser" do
      assert seed["AuditorUser"][:created], "AuditorUser was created"
    end

    it "should create a new LenderAdmin" do
      pending "TODO"
      assert seed["LenderAdmin"][:created], "LenderAdmin was created"
    end

    it "should create a new LenderUser" do
      pending "TODO"
      assert seed["LenderUser"][:created], "LenderUser was created"
    end
  end

  describe "with no lenders / loans" do
    it "should create a new CfeAdmin" do
      assert seed["CfeAdmin"][:created], "CfeAdmin was created"
    end

    it "should create a new CfeUser" do
      assert seed["CfeUser"][:created], "CfeUser was created"
    end

    it "should create a new PremiumCollectorUser" do
      assert seed["PremiumCollectorUser"][:created], "PremiumCollectorUser was created"
    end

    it "should create a new AuditorUser" do
      assert seed["AuditorUser"][:created], "AuditorUser was created"
    end

    it "should not create a LenderAdmin" do
      seed["LenderAdmin"].should be nil
    end

    it "should not create a LenderUser" do
      seed["LenderUser"].should be nil
    end
  end
end