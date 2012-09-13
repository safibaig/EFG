require 'spec_helper'

describe SupportRequestController do

  describe '#new' do
    def dispatch
      get :new
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

  describe '#create' do
    def dispatch
      get :create, { message: "Help!" }
    end

    it_behaves_like 'AuditorUser-restricted controller'
    it_behaves_like 'CfeAdmin-restricted controller'
    it_behaves_like 'PremiumCollectorUser-restricted controller'
  end

end
