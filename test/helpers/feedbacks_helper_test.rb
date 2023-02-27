class FeedbacksHelperTest < ActionView::TestCase
  include FeedbacksHelper
 
  def test_week_range 
    week_range = week_range(2021, 7)
    assert_equal("2021-02-15 00:00", week_range[:start_date].strftime("%Y-%m-%d %H:%M"))
    assert_equal("2021-02-21 23:59", week_range[:end_date].strftime("%Y-%m-%d %H:%M"))

    # Check appropriate dates are inside range
    assert(Time.zone.local(2021, 2, 15, 1, 00) > week_range[:start_date])
    assert(Time.zone.local(2021, 2, 21, 23, 30) < week_range[:end_date])
    
    # Check inappropriate dates are outside range
    assert(Time.zone.local(2021, 2, 14, 23, 59) < week_range[:start_date])
    assert(Time.zone.local(2021, 2, 22, 0, 00) > week_range[:end_date])
  end
  
  def test_days_till_end_same_day
    date = Time.zone.local(2021, 3, 21).to_datetime
    assert_equal(0, days_till_end(date, 11, 2021))
  end
  
  def test_days_till_end_one_day 
    date = Time.zone.local(2021, 3, 20).to_datetime
    assert_equal(1, days_till_end(date, 11, 2021))
  end
  
  def test_days_till_end_first_day
    date = Time.zone.local(2021, 3, 15).to_datetime
    assert_equal(6, days_till_end(date, 11, 2021))
  end
end