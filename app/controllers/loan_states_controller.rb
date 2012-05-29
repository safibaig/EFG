class LoanStatesController < ApplicationController
  def index
    @states = Loan::States.map { |state|
      OpenStruct.new(
        loan_count: current_lender.loans.where(state: state).count,
        name: state
      )
    }
  end

  def show
    @loans = current_lender.loans.with_state(params[:id])
  end
end
