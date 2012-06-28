module LoanDetailsTableHelper
  class LoanDetailsTable < ActionView::Base
    Formats = {
      TrueClass => 'Yes',
      FalseClass => 'No',
      NilClass => 'Not Set'
    }

    def initialize(loan, translation_scope)
      @loan, @translation_scope = loan, translation_scope
    end

    attr_reader :loan, :translation_scope

    def row(attribute)
      content_tag(:tr) do
        header = I18n.t("#{translation_scope}.#{attribute}")
        value = loan.send(attribute)
        content_tag(:th, header) + content_tag(:td, format(value))
      end
    end

    private
    def format(value)
      Formats[value.class]
    end
  end

  def loan_details_table(loan, translation_scope)
    table = LoanDetailsTable.new(loan, translation_scope)
    content_tag(:table, class: 'table table-striped table-loan-details') do
      yield table
    end
  end
end
