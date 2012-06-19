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

    %w(high medium low).each do |p|
      links << link_to("#{p.titleize} Priority Alerts", url_for(priority: p), class: 'btn') unless priority == p
    end

    links << link_to("All Loan Alerts", url_for, class: 'btn') if priority

    content_tag :div, class: 'form-actions' do
      links.join.html_safe
    end
  end

end
