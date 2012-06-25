class SearchController < ApplicationController

  def show
    @loans = current_lender.loans.by_reference(params[:term]).paginate(page: params[:page])
    respond_to do |format|
      format.html do
        if @loans.count == 1
          redirect_to loan_path(@loans.first, term: params[:term]) and return
        end
      end
      format.json { render json: @loans.collect(&:reference) }
    end
  end

end
