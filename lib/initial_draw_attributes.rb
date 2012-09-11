module InitialDrawAttributes
  def initial_draw_amount
    initial_draw_change.try :amount_drawn
  end

  def initial_draw_date
    initial_draw_change.try :date_of_change
  end
end
