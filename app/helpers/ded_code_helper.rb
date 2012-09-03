module DedCodeHelper

  def ded_code_options_for_select
    grouped_options_for_select(grouped_ded_codes)
  end

  def grouped_ded_codes
    ded_codes_by_category = DedCode.all.group_by(&:category_description)
    grouped_ded_codes = ded_codes_by_category.inject({}) do |memo, (category, ded_codes)|
      memo[category] = ded_codes.map { |ded_code| [ "#{ded_code.code} - #{ded_code.code_description}", ded_code.code ] }
      memo
    end
  end

end
