import_namespace = namespace :import do
  desc 'Import all CSVs'
  task :all do
    import_namespace.tasks.each do |task|
      task.invoke unless task.name.split(':').last == 'all'
    end
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
  task loan_changes: :loans do
    _import LoanChange
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
    _import Loan
  end

  desc 'SFLG_RECOVERY_STATEMENT_DATA_TABLE'
  task realisation_statement: [:users, :loans] do
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

  desc 'SFLG_DED_DATA_TABLE'
  task ded_code: :environment do
    _import DedCode
  end

  desc 'SFLG_LOAN_RR_DATA_TABLE'
  task loan_ineligibility_reasons: [:loans] do
    _import LoanIneligibilityReason
  end

  desc 'SIC_2007_DATA'
  task sic_code: :environment do
    _import SicCode
  end

  def _import(klass)
    if klass.count.zero?
      require 'importers'
      importer = "#{klass.name}Importer".constantize
      importer.import
      yield if block_given?
    else
      puts "Did not import #{klass.table_name} - table is not empty."
    end
  end
end
