module SicCodeHelper

  def sic_code_options
    SicCode.all.map { |sic_code| [ "#{sic_code.code}: #{sic_code.description}", sic_code.code ] }
  end

end
