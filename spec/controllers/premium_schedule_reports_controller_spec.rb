require 'spec_helper'

describe PremiumScheduleReportsController do
  describe '#new' do
    def dispatch
      get :new
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      post :create, { premium_schedule_report: {} }
    end

    it_behaves_like 'CfeUser-restricted controller'
    it_behaves_like 'LenderUser-restricted controller'
  end
end
