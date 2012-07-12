# Loan reference structure is:
#
#  {7 random uppercase characters and numbers}{loan type separator (+ for EFG, - for SFLG)}{version number}
#
#  E.g. D54QT9C+01
#
class LoanReference

  REFERENCE_LENGTH = 7

  LETTERS_AND_NUMBERS = ('A'..'Z').to_a + (0..9).to_a

  INITIAL_VERSION = "01"

  def self.generate
    reference = create_reference_string
    Loan.exists?(reference: reference) ? generate : reference
  end

  private

  def self.create_reference_string
    (0...REFERENCE_LENGTH).map { |n| LETTERS_AND_NUMBERS.sample }.join + "+" + INITIAL_VERSION
  end

end
