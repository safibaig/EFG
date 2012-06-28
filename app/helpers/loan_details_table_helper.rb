module LoanDetailsTableHelper
  class LoanDetailsTable < ActionView::Base
    Formats = {
      ActiveSupport::TimeWithZone => ->(time) { time.strftime('%d/%m/%Y %H:%M:%S') },
      Date => ->(date) { date.strftime('%d/%m/%Y') },
      FalseClass => 'No',
      InterestRateType => ->(interest_rate_type) { interest_rate_type.name },
      LegalForm => ->(legal_form) { legal_form.name },
      Lender => ->(lender) { lender.name },
      LoanAllocation => ->(loan_allocation) { loan_allocation.title },
      LoanCategory => ->(loan_category) { loan_category.name },
      Money => ->(money) { money.format },
      MonthDuration => ->(duration) { duration.format },
      NilClass => 'Not Set',
      TrueClass => 'Yes',
      User => ->(user) { user.name }
    }

    def initialize(loan, translation_scope)
      @loan, @translation_scope = loan, translation_scope
    end

    attr_reader :loan, :translation_scope

    def row(attribute, options = {})
      content_tag(:tr) do
        header = options.fetch(:header, I18n.t("#{translation_scope}.#{attribute}"))
        value = loan.send(attribute)
        content_tag(:th, header) + content_tag(:td, format(value))
      end
    end

    private
    def format(value)
      formatted_value = Formats.fetch(value.class, value)
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
