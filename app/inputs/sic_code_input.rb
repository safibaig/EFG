class SICCodeInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'sic-code-input') do
      @builder.select(
        attribute_name,
        options_for_select,
        input_options,
        input_html_options
      ) + restricted_eligibility_message
    end
  end

  def options
    super.reverse_merge(prompt: 'Please select')
  end

  def options_for_select
    options[:collection].map do |sic_code|
      opts = sic_code.public_sector_restricted? ? { 'data-eligibility' => 'restricted' } : {}
      [ "#{sic_code.code}: #{sic_code.description}", sic_code.code, opts ]
    end
  end

  private

  def restricted_eligibility_message
    %Q{
      <div class="sic-code-restricted-eligibility">
        <span class="label label-important">
          <i class="icon-exclamation-sign"></i>
          This SIC code is not eligible for public sector businesses.
          Please verify the business applying for this loan is not in
          the public sector before continuing.
        </span>
      </div>
    }.html_safe
  end
end

SicCodeInput = SICCodeInput
