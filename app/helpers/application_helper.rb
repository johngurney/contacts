module ApplicationHelper

  include ActionView::Helpers::FormTagHelper

  def from_number_to_card(n)
    if n>= 0

      if n < 13
        stg = "c"
      elsif n < 26
        stg = "d"
      elsif n < 39
        stg = "h"
      else
        stg = "s"
      end

      n = n % 13

      if n < 10
        stg += (n + 1).to_s
      elsif n == 10
        stg += "j"
      elsif n  == 11
        stg += "q"
      else
        stg += "k"
      end
    else
      if n == -1
        stg = "b"
      else
        stg = "j"
      end
    end

    stg
  end


  def card_filename(n)

    filename = ""

    if n == "b"
      filename="back"
    elsif n == "j"
      filename = "joker"

    else

      case n[0,1].downcase
      when "c"
        filename = "clubs"
      when "d"
        filename = "diamonds"
      when "h"
        filename = "hearts"
      when "s"
        filename = "spades"
      else
        return
      end

      filename += "_"

      case n[1,1].downcase
      when "1"
        filename += "ace"
      when "2"
        filename += "two"
      when "3"
        filename += "three"
      when "4"
        filename += "four"
      when "5"
        filename += "five"
      when "6"
        filename += "six"
      when "7"
        filename += "seven"
      when "8"
        filename += "eight"
      when "9"
        filename += "nine"
      when "0"
        filename += "ten"
      when "j"
        filename += "jack"
      when "q"
        filename += "queen"
      when "k"
        filename += "king"
      end
    end

    "cards/" + filename + ".jpg"

  end



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

  def enable_crib(player)
    Card.where(:position => "crib", :player => player).count < 2
  end

  def enable_play(player)
    Card.where(:position => "deckshow").count > 0
  end

  def play_turnover(player)
    p1 = Card.where(:position => "playopen", :player => player).count
    p2 = Card.where(:position => "playturned", :player => player).count
    (p1 > 0 && p1 < 4) || (p2 == 4)
  end


end
