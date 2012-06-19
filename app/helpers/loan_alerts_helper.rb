module LoanAlertsHelper

  def loan_alerts_priority(priority)
    return if priority.blank?
    secondary_class_name = case priority
    when "high"
      'label-important'
    when "medium"
      'label-warning'
    when "low"
      'label-success'
    end

    if params[:priority]
      content_tag(:div, "#{params[:priority].titleize} Priority", class: "label #{secondary_class_name}")
    end
  end

  def other_alert_links(priority)
    links = []
    links << link_to("High Priority Alerts", url_for(priority: :high), class: 'btn btn-danger') unless priority == 'high'
    links << link_to("Medium Priority Alerts", url_for(priority: :medium), class: 'btn btn-warning') unless priority == 'medium'
    links << link_to("Low Priority Alerts", url_for(priority: :high), class: 'btn btn-success') unless priority == 'low'
    links << link_to("All Loan Alerts", url_for, class: 'btn btn-primary') if priority

    content_tag :div, class: 'form-actions' do
      links.join.html_safe
    end
  end

end
