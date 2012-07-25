# Legacy SFLG Loan reference structure is a number between 10000 and 999999,
# plus an optional version number depending on whether it has been transferred
#
# A loan that has been transferred, will have a version number starting at -02 e.g. 100012-02

class InvalidLegacyLoanReference < ArgumentError; end;

class LegacyLoanReference

  VALID_REFERENCE_REGEX = /^(\d){5,6}(-\d{2})?$/

  def initialize(reference)
    @reference = reference
    raise InvalidLegacyLoanReference, "#{reference} is not a valid legacy loan reference" unless valid_reference?
  end

  # if reference already has a version number, increment it by 1
  # otherwise, add -02 to the end of the reference
  def increment
    if @reference.match(/-\d{2}$/)
      new_version = "%02d" % (@reference[-2,2].to_i + 1)
      @reference.gsub(/\d{2}$/, new_version)
    else
      @reference + "-02"
    end
  end

  private

  def valid_reference?
    @reference && @reference.match(VALID_REFERENCE_REGEX)
  end

end
