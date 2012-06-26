class SearchController < ApplicationController

  def new
  end

  def lookup
    @loans = current_lender.loans.by_reference(params[:term]).paginate(page: params[:page])
    respond_to do |format|
      format.html do
        if @loans.count == 1
          redirect_to loan_path(@loans.first, term: params[:term]) and return
        end
        render template: "search/results"
      end
      format.json { render json: @loans.collect(&:reference) }
    end
  end

  def basic
    @loans = BasicSearch.new(current_lender, params[:loan]).loans.paginate(page: params[:page])
    render template: "search/results"
  end

end
