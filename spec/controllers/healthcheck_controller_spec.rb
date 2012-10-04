require 'spec_helper'

describe HealthcheckController do
  describe "#index" do
    it "should return success" do
      get :index
      response.should be_success
    end
  end
end
