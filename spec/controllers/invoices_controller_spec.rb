require 'spec_helper'

describe InvoicesController do
  describe "GET show" do
    let(:invoice) { FactoryGirl.create(:invoice) }

    def dispatch
      get :show, id: invoice.id
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
