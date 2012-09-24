class TransferredLoanImporter < BaseImporter
  self.csv_path = Rails.root.join('import_data/SFLG_LOAN_DATA_TABLE.csv')

  def self.import
    File.open(csv_path, "r:utf-8") do |file|
      csv = CSV.new(file, headers: true)
      csv.extend(CSVProgressBar) unless Rails.env.test?
      csv.each do |row|
        next if row['TRANSFERRED_FROM'].blank?

        loan_id = self.loan_id_from_legacy_id(row['OID'])
        transferred_from_id = self.loan_id_from_legacy_id(row['TRANSFERRED_FROM'])
        Loan.where(id: loan_id).update_all(transferred_from_id: transferred_from_id)
      end
    end
  end

end
