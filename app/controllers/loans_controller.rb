class LoansController < ApplicationController
  def index
    @states = Loan::States.map { |state|
      OpenStruct.new(
        loan_count: current_lender.loans.where(state: state).count,
        name: state
      )
    }
  end

  def show
    @loan = current_lender.loans.find(params[:id])
  end
end
