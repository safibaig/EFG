class SearchController < ApplicationController

  def show
    @search = Search.new(current_lender, params[:search])
    @results = @search.results.paginate(page: params[:page])
    render template: "search/results"
  end

  def new
    @search = Search.new(current_lender, params[:search])
  end

  def lookup
    @results = current_lender.loans.by_reference(params[:term]).paginate(page: params[:page])
    respond_to do |format|
      format.html do
        if @results.count == 1
          redirect_to loan_path(@results.first, term: params[:term]) and return
        end
        render template: "search/results"
      end
      format.json { render json: @results.collect(&:reference) }
    end
  end
end
