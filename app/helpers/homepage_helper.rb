module HomepageHelper

  def update_frequency_options()
    n = 1
    a = []
    t, stg = update_frequency_values(n)
    while (stg != "")
      a << [stg, n]
      n += 1
      t, stg = update_frequency_values(n)
    end
    a
  end

  def last_posting_options()
    n = 1
    a = []
    t, stg = last_posting_values(n)
    while (stg != "")
      a << [stg, n]
      n += 1
      t, stg = last_posting_values(n)
    end
    a
  end

  def update_frequency_values(value)
    case value
    when 1
      return 15, "15 secs"
    when 2
      return 60, "1 min"
    when 3
      return 120, "2 mins"
    when 4
      return 5, "5 mins"
    when 5
      return 0, "On refresh"
    else
      return 0, ""
    end
    #"15 secs", "30 secs", "1 min", "2 mins", "5 mins", "On refresh"
  end

  def last_posting_values(value)
    case value
    when 1
      return 10 * 60, "10 mins"
    when 2
      return 30 * 60, "30 mins"
    when 3
      return 60 * 60, "1 hour"
    when 4
      return 3 * 60 * 60, "3 hours"
    when 5
      return 6 * 60 * 60, "6 hours"
    when 6
      return 12 * 60 * 60, "12 hours"
    when 7
      return 24 * 60 * 60, "1 day"
    when 8
      return 7 * 24 * 60 * 60, "1 week"
    when 9
      return 0, "Ever"
    else
      return 0, ""
    end
    #"10 mins", "1 hr", "1 min", "Ever"
  end

  def select_logs(logs, value)
    if last_posting_values(value)[0] == 0
      logs
    else
      logs.where("created_at <= ?", last_posting_values(value)[0].seconds.ago)
    end
  end

end
