class LoanStatesController < ApplicationController

  def index
    # TODO: Don't do N queries.
    @states = Loan::States.map { |state|
      OpenStruct.new(
        id: state,
        loan_count: current_lender.loans.where(state: state).count,
        name: state.titleize
      )
    }
  end

  def show
    @loans = current_lender.loans.with_state(params[:id])
    respond_to do |format|
      format.html { @loans = @loans.paginate(per_page: 50, page: params[:page]) }
      format.csv do
        filename = "#{params[:id]}_loans_#{Date.today.strftime('%d-%m-%Y')}.csv"
        csv_export = LoanCsvExport.new(@loans)
        send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
      end
    end
  end

end
