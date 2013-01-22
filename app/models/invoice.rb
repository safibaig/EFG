class Invoice < ActiveRecord::Base
  PERIOD_COVERED_QUARTERS = ['March', 'June', 'September', 'December']

  belongs_to :lender
  belongs_to :created_by, class_name: 'User'
  has_many :settled_loans, class_name: 'Loan', foreign_key: 'invoice_id'

  validates_presence_of :lender_id, strict: true
  validates_presence_of :reference, strict: true
  validates_presence_of :received_on, strict: true
  validates_presence_of :created_by, strict: true

  validates_presence_of :period_covered_quarter, strict: true
  validates_inclusion_of :period_covered_quarter, in: PERIOD_COVERED_QUARTERS, strict: true

  validates_presence_of :period_covered_year, strict: true
  validates_format_of :period_covered_year, with: /\A(\d{4})\Z/, strict: true

  before_create :generate_xref, unless: :xref

  private
    def generate_xref
      string = random_xref
      if self.class.exists?(xref: string)
        generate_xref
      else
        self.xref = string
      end
    end

    def random_xref
      6.times.map { |n| (0..9).to_a.sample }.join + '-INV'
    end
end
