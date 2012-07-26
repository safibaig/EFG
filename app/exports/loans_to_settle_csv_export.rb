class InvoiceCsvExport < BaseCsvExport

  private

  # TODO add Outstanding Balance, Eligible Outstanding Interest
  # and Amount of Claim (Guaranteed Percentage) when available
  def fields
    %w(
      reference
      business_name
      dti_demanded_on
    )
  end

end