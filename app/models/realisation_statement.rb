class RealisationStatement < ActiveRecord::Base
  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :loan_realisations
  has_many :realised_loans, through: :loan_realisations
  has_many :recoveries

  validates_presence_of :lender_id, strict: true
  validates_presence_of :created_by, strict: true
  validates_presence_of :reference, strict: true
  validates_presence_of :received_on, strict: true

  validates_presence_of :period_covered_quarter, strict: true
  validates_inclusion_of :period_covered_quarter, in: PERIOD_COVERED_QUARTERS, strict: true

  validates_presence_of :period_covered_year, strict: true
  validates_format_of :period_covered_year, with: /\A(\d{4})\Z/, strict: true
end
