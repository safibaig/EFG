module MemorablePassword
  # A very simple wrapper around Haddock, so we can switch this out for
  # something else later on - if needed.
  def self.generate
    Haddock::Password.generate
  end
end
