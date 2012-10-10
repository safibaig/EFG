import_namespace = namespace :import do
  desc 'Import all CSVs'
  task :all do
    import_namespace.tasks.each do |task|
      task_name = task.name.split(":").last
      task.invoke unless ["all", "dry_run"].include?(task_name)
    end
  end

  desc "List files required for import"
  task dry_run: :environment do
    missing = [
      AdminAudit,
      DedCode,
      DemandToBorrower,
      Invoice,
      Lender,
      LendingLimit,
      Loan,
      LoanIneligibilityReason,
      LoanModification,
      LoanRealisation,
      LoanSecurity,
      LoanStateChange,
      RealisationStatement,
      Recovery,
      SicCode,
      StateAidCalculation,
      User,
      UserAudit,
    ].inject([]) { |acc, klass|
      csv_file = _importer_class(klass).csv_path
      acc << csv_file unless File.exists?(csv_file)
      acc
    }

    if missing.empty?
      puts "All files present!"
    else
      puts "The following files appear to be missing:"
      puts missing
    end
  end

  desc 'SFLG_ADMIN_AUDIT_DATA_TABLE'
  task admin_audits: [:lending_limits, :users] do
    _import AdminAudit
  end

  desc 'SFLG_DEMAND_TO_BORROWER_DATA_TABLE'
  task demand_to_borrowers: [:loans, :users] do
    _import DemandToBorrower
  end

  desc 'SFLG_INVOICE_DATA_TABLE'
  task invoices: [:lenders, :users] do
    _import Invoice
  end

  desc 'SFLG_LENDER_DATA_TABLE'
  task lenders: :environment do
    _import Lender
  end

  desc 'SFLG_LENDER_CAP_ALLOC_DATA_TABLE)'
  task lending_limits: :lenders do
    _import LendingLimit
  end

  desc 'SFLG_LOAN_CHANGES_DATA_TABLE'
  task loan_modifications: :loans do
    _import LoanModification
  end

  desc 'SFLG_LOAN_REALISE_MONEY_DATA_TABLE'
  task loan_realisations: [:users, :loans] do
    _import LoanRealisation
  end

  desc 'SFLG_LOAN_SECURITY_DATA_TABLE'
  task loan_securities: :loans do
    _import LoanSecurity
  end

  desc 'SFLG_LOAN_AUDIT_DATA_TABLE'
  task loan_state_changes: :loans do
    _import LoanStateChange
  end

  desc 'SFLG_LOAN_DATA_TABLE'
  task loans: [:invoices, :lending_limits] do
    _import Loan do
      TransferredLoanImporter.import
    end
  end

  desc 'SFLG_RECOVERY_STATEMENT_DATA_TABLE'
  task realisation_statements: [:users, :loans] do
    _import RealisationStatement
  end

  desc 'SFLG_LOAN_RECOVERED_DATA_TABLE'
  task recoveries: [:users, :loans] do
    _import Recovery
  end

  desc 'SFLG_CALCULATORS_DATA_TABLE'
  task state_aid_calculations: :loans do
    _import StateAidCalculation
  end

  desc 'SFLG_USER_DATA_TABLE'
  task users: :lenders do
    _import User do
      LenderUserAssociationImporter.import
    end
  end

  desc 'SFLG_USER_AUDIT_DATA_TABLE'
  task user_audits: :users do
    _import UserAudit
  end

  desc 'SFLG_DED_DATA_TABLE'
  task ded_codes: :environment do
    _import DedCode
  end

  desc 'SFLG_LOAN_RR_DATA_TABLE'
  task loan_ineligibility_reasons: [:loans] do
    _import LoanIneligibilityReason
  end

  desc 'SIC_2007_DATA'
  task sic_codes: :environment do
    _import SicCode
  end

  def _import(klass)
    if klass.count.zero?
      _importer_class(klass).import
      yield if block_given?
    else
      puts "Did not import #{klass.table_name} - table is not empty."
    end
  end

  def _importer_class(klass)
    require 'importers'
    "#{klass.name}Importer".constantize
  end
end
