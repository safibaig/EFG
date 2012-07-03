require 'spec_helper'

describe PremiumSchedule do
  describe "calculations" do
    let(:state_aid_calculation) {
      FactoryGirl.build(:state_aid_calculation,
        initial_draw_amount: Money.new(100_000_00),
        initial_draw_months: 120)
    }
    let(:premium_schedule) { PremiumSchedule.new(state_aid_calculation) }

    it "calcuates quarterly premiums" do
      [
        500_00, 487_50, 475_00, 462_50, 450_00, 437_50, 425_00, 412_50, 400_00,
        387_50, 375_00, 362_50, 350_00, 337_50, 325_00, 312_50, 300_00, 287_50,
        275_00, 262_50, 250_00, 237_50, 225_00, 212_50, 200_00, 187_50, 175_00,
        162_50, 150_00, 137_50, 125_00, 112_50, 100_00, 87_50, 75_00, 62_50,
        50_00, 37_50, 25_00, 12_50
      ].each.with_index do |premium, quarter|
        premium_schedule.premiums[quarter].should == Money.new(premium)
      end
    end

    it "calculates total premiums" do
      premium_schedule.total_premiums.should == Money.new(10_250_00)
    end
  end
end
