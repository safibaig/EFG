# encoding: utf-8

class Flashes::StateAidCalculationFlashMessage < ActionView::Base
  def initialize(state_aid_calculation)
    # Store only the minimum information in instance varaibles as this object
    # is serialised, via the session, to a cookie.
    @state_aid_eur = state_aid_calculation.state_aid_eur.format
  end

  attr_reader :state_aid_eur

  def render(context, type)
    content_tag(:div, class: ['alert', 'alert-block', "alert-#{type}"]) do
      content_tag(:h4, header) +
        content_tag(:p, recalculated_figure) +
        content_tag(:p, additional_information)
    end
  end

  private
  def header
    'State Aid Calculation'
  end

  def recalculated_figure
    figure = content_tag(:strong, state_aid_eur)
    "The recalculated De Minimis figure is #{figure}.".html_safe
  end

  def additional_information
    "If you believe there are any issues with regards to the recalculated De Minimis figure i.e. the total value of the Applicant's De Minimis State Aid for the last three years (including that arising from this application) is now more than €200,000 - or the relevant lower threshold where advised for eligible agriculture, fisheries and transport businesses – then please cancel the facility. If there isn't an issue, then please progress as you would do ordinarily.".html_safe
  end
end
