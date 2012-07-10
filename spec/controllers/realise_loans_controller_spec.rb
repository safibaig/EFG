require 'spec_helper'

describe RealiseLoansController do

  describe "GET show" do
    let(:realisation_statement) { FactoryGirl.create(:realisation_statement) }

    def dispatch
      get :show, id: realisation_statement.id
    end

    it_behaves_like 'CfeUser-only controller'
  end

  describe "GET new" do
    def dispatch
      get :new
    end

    it_behaves_like 'CfeUser-only controller'
  end

  describe "POST select_loans" do
    def dispatch
      post :select_loans
    end

    it_behaves_like 'CfeUser-only controller'
  end

  describe "POST create" do
    def dispatch
      post :create
    end

    it_behaves_like 'CfeUser-only controller'
  end

end
