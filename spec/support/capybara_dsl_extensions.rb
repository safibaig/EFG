module CapybaraDSLExtensions
  include Capybara::DSL

  def select_option_value(option_value, options = {})
    field_name = options.fetch(:from)
    field = find(:select, field_name)
    field.find(:xpath, "//option[@value='#{option_value}']").select_option
  end
end
