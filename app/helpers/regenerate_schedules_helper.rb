module RegenerateSchedulesHelper

  def reschedule_form_label(key)
    t("simple_form.labels.regenerate_schedule.#{key}")
  end

  def loan_change_hidden_fields(hash)
    if hash.is_a?(Hash)
      %w(
        amount_drawn
        business_name
        change_type_id
        date_of_change
        lump_sum_repayment
        maturity_date
      ).collect do |field|
        hidden_field_tag "loan_change[#{field}]", hash[field.to_sym]
      end.join.html_safe
    end
  end

end