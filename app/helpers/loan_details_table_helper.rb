module LoanDetailsTableHelper
  class LoanDetailsTable < ActionView::Base
    Formats = {
      TrueClass => 'Yes',
      FalseClass => 'No',
      NilClass => 'Not Set',
      Date => ->(date) { date.strftime('%d/%m/%Y') }
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
      formatted_value = Formats[value.class]
      if formatted_value.respond_to?(:call)
        formatted_value = formatted_value.call(value)
      end
      formatted_value
    end
  end

  def loan_details_table(loan, translation_scope)
    table = LoanDetailsTable.new(loan, translation_scope)
    content_tag(:table, class: 'table table-striped table-loan-details') do
      content_tag(:tbody) do
        yield table
      end
    end
  end
end
