module ApplicationHelper
  def colors
    '["red", "olive", "navy", "teal", "black", "orange", "green", "magenta"]'.html_safe
  end

  def time_from_to(h, s)
    t = Time.new(2000,1,1,h,0,0)
    t_stg1 = t.strftime("%l:%M%P")

    t += s.hour - 1.minute
    t_stg2 = t.strftime("%l:%M%P")

    t_stg1 + " to " + t_stg2

  end
end
