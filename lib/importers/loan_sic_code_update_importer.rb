require 'csv'
require 'csv_progress_bar'

class LoanSicCodeUpdateImporter

  class << self
    attr_accessor :csv_path
  end

  self.csv_path = Rails.root.join('import_data/LOAN_SIC_CODE_MAPPING.csv')

  def self.import
    File.open(csv_path, "r:utf-8") do |file|
      csv = CSV.new(file, headers: true)
      csv.extend(CSVProgressBar) unless Rails.env.test?

      Loan.record_timestamps = false

      csv.each do |row|
        next if row['SIC 2007'].blank?
        loan_reference = row['Loan reference']
        new_sic_code   = row['SIC 2007'].rjust(5, '0')

        if loan = Loan.find_by_reference(loan_reference)
          sic_code              = SicCode.find_by_code(new_sic_code)
          loan.sic_code         = sic_code.code
          loan.sic_desc         = sic_code.description
          loan.sic_eligible     = sic_code.eligible
          loan.sic_parent_desc  = nil
          loan.sic_notified_aid = nil
          loan.save(validate: false)
        end
      end

      Loan.record_timestamps = true
    end
  end

end
