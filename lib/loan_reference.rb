# Loan reference structure is:
#
#  {7 random uppercase characters and numbers}{loan type separator (+ for EFG, - for SFLG)}{version number}
#
#  E.g. D54QT9C+01
#

class InvalidLoanReference < ArgumentError; end;

class LoanReference

  REFERENCE_LENGTH = 7

  LETTERS_AND_NUMBERS = ('A'..'Z').to_a + (0..9).to_a

  INITIAL_VERSION = "01"

  # a valid reference can have a + or - separator
  VALID_REFERENCE_REGEX = /^([A-Z]|[0-9]){#{REFERENCE_LENGTH}}(\+|-)\d{2}$/

  def self.generate
    string = create_reference_string
    Loan.exists?(reference: string) ? generate : string
  end

  def initialize(reference)
    @reference = reference
    raise InvalidLoanReference, "#{reference} is not a valid loan reference" unless valid_reference?
  end

  def increment
    version = @reference[-2,2].to_i
    new_version = "%02d" % (version + 1)
    @reference[0, REFERENCE_LENGTH + 1] + new_version
  end

  private

  def self.create_reference_string
    string = random_string
    return create_reference_string if string.last == 'E'
    string + "+" + INITIAL_VERSION
  end

  def self.random_string
    (0...REFERENCE_LENGTH).map { |n| LETTERS_AND_NUMBERS.sample }.join
  end

  def valid_reference?
    @reference.match(VALID_REFERENCE_REGEX)
  end

end
