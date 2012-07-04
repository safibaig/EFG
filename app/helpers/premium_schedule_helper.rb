module PremiumScheduleHelper
  def premiums_table_rows(premiums)
    limit = (premiums.length  / 2.0).ceil + 1

    left_column, right_column = (premiums
      .map.with_index {|premium, i| [i + 1, premium]}
      .partition {|(i, _)| i < limit})

    left_column.zip(right_column)
  end
end
