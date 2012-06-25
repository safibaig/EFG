class SearchController < ApplicationController

  def show
    @loans = current_lender.loans.by_reference(params[:reference]).paginate(page: params[:page])
  end

end
