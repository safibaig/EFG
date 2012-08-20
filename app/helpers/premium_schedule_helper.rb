module PremiumScheduleHelper

  # Note: rescheduled premium schedules display the first premium
  #       standard premium schedules start with the second premium
  def premiums_table_rows(premiums, is_reschedule)
    limit = (premiums.length / 2.0).ceil
    limit += 1 unless is_reschedule

    left_column, right_column = (premiums
      .map.with_index do |premium, i|
        index = is_reschedule ? i : i + 1
        [index, premium]
      end.partition {|(i, _)| i < limit})

    left_column.zip(right_column)
  end

  def premium_number_cell(index)
    class_name = "premium#{index + 1}" if index.is_a?(Fixnum)
    content_tag :td, class: class_name do
      (index + 1).to_s if index.is_a?(Fixnum)
    end
  end

  def premium_amount_cell(premium)
    content_tag :td do
      premium.format if premium.present?
    end
  end

  def premium_schedule_title(premium_schedule)
    premium_schedule.reschedule? ? "Revised Premium Schedule" : "Premium Schedule"
  end

end
