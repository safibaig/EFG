class LoanStatesController < ApplicationController
  before_filter :verify_view_permission

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
        filename = "#{params[:id]}_loans_#{Date.today.to_s(:db)}.csv"
        csv_export = LoanCsvExport.new(@loans)
        send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
      end
    end
  end

  private
    def verify_view_permission
      enforce_view_permission(Loan::States)
    end
end
