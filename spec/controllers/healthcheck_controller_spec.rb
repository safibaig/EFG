require 'spec_helper'

describe HealthcheckController do
  describe "#index" do
    it "should return success" do
      get :index
      response.should be_success
    end

    it "should fail when the database isn't available" do
      Lender.stub(:count).and_raise(Mysql2::Error.new("Database unavailable"))
      assert_raise Mysql2::Error do
        get :index
      end
    end
  end
end
