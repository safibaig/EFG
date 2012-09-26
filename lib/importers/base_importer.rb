require 'csv'
require 'csv_progress_bar'

class BaseImporter
  class << self
    attr_accessor :csv_path
    attr_accessor :klass
    attr_accessor :validate
  end

  attr_accessor :attributes, :row

  LOAN_STATE_MAPPING = {
    "1" => Loan::Rejected,
    "2" => Loan::Eligible,
    "3" => Loan::Cancelled,
    "4" => Loan::Incomplete,
    "5" => Loan::Completed,
    "6" => Loan::Offered,
    "7" => Loan::AutoCancelled,
    "8" => Loan::Guaranteed,
    "9" => Loan::LenderDemand,
    "10" => Loan::Repaid,
    "11" => Loan::Removed,
    "12" => Loan::RepaidFromTransfer,
    "13" => Loan::AutoRemoved,
    "14" => Loan::NotDemanded,
    "15" => Loan::Demanded,
    "16" => Loan::Settled,
    "17" => Loan::Realised,
    "18" => Loan::Recovered,
    "19" => Loan::IncompleteLegacy,
    "20" => Loan::CompleteLegacy,
  }

  def initialize(row)
    @row = row
    @attributes = self.class.empty_attributes.dup
    build_attributes
  end

  def self.bulk_import(values)
    klass.import(columns, values, validate: false, timestamps: false)
  end

  # An ordered list of database columns that will be INSERTed into the
  # table. It is imperative that this order matches the order of the
  # `values` instance method list.
  def self.columns
    field_mapping.values + extra_columns
  end

  def self.empty_attributes
    @empty_attributes ||= columns.inject({}) { |memo, key|
      memo[key] = nil
      memo
    }
  end

  def self.extra_columns
    []
  end

  def self.field_mapping
    {}
  end

  def self.import
    values = []

    File.open(csv_path, "r:utf-8") do |file|
      csv = CSV.new(file, headers: true)
      csv.extend(CSVProgressBar) unless Rails.env.test?
      csv.each do |row|
        values << new(row).values

        if values.length % 1000 == 0
          bulk_import(values)
          values.clear
        end
      end

      bulk_import(values) unless values.empty?
    end

    after_import if respond_to?(:after_import, true)
  end

  def self.lender_id_from_legacy_id(legacy_id)
    @lender_id_from_legacy_id ||= Hash[Lender.select('id, legacy_id').map { |lender|
      [lender.legacy_id.to_s, lender.id]
    }]

    @lender_id_from_legacy_id.fetch(legacy_id.to_s)
  end

  def self.lending_limit_id_from_legacy_id(legacy_id)
    @lending_limit_id_from_legacy_id ||= Hash[LendingLimit.select('id, legacy_id').map { |lending_limit|
      [lending_limit.legacy_id.to_s, lending_limit.id]
    }]

    @lending_limit_id_from_legacy_id.fetch(legacy_id.to_s)
  end

  def self.loan_id_from_legacy_id(legacy_id)
    @loan_id_from_legacy_id ||= begin
      {}.tap { |lookup|
        Loan.select('id, legacy_id').find_each do |loan|
          lookup[loan.legacy_id] = loan.id
        end
      }
    end

    @loan_id_from_legacy_id.fetch(legacy_id.to_i)
  end

  def self.user_id_from_username(legacy_id)
    @user_id_from_username ||= begin
      {}.tap { |lookup|
        User.select('id, username').find_each do |user|
          lookup[user.username] = user.id
        end
      }
    end

    # return system user ID if legacy_id not found
    @user_id_from_username.fetch(legacy_id, -1)
  end

  def build_attributes
    row.each do |key, value|
      attributes[self.class.field_mapping[key]] = value
    end
  end

  # An ordered list of values that will be INSERTed into the table using a
  # VALUES list. It is imperative that this order matches the order of the
  # `self.class.columns` list.
  def values
    attributes.values
  end
end
