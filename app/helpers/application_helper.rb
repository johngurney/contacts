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
    Card.where(:position => "hand", :game_id => player.game_id, :player_id => player.id).count > 4
  end

  def enable_play(player)
    Card.where(:game_id => player.game_id, :position => "deckshow").count > 0
  end

  def play_turnover(player)
    #Open cards in play    Turned cards in play     Cards in all hands
    #>=1, <4               >=1, <4                  0                     TRUE
    #0                     4                        0                     TRUE
    #4                     0                        0                     FALSE
    #>1, <4                >1, <4                   >= 1                  TRUE
    #0                     <4                       >= 1                  FALSE
    #<4                    0                        >= 1                  TRUE

    cards_in_all_hands = Card.where(:game_id => player.game_id, :position => "hand").count
    open_cards_in_players_play = Card.where(:position => ["justplayed", "playopen"], :game_id => player.game_id, :player_id => player.id).count
    turned_cards_in_players_play = Card.where(:position => "playturned", :game_id => player.game_id, :player_id => player.id).count
    ((cards_in_all_hands != 0) && (open_cards_in_players_play != 0)) || ((cards_in_all_hands == 0) && (turned_cards_in_players_play != 0))
  end

  def available_crib_players(log_out_wording)
    players = []
    (1..2).each do |n|
      player = Cribplayer.where(:number => n).first
      players << ["Player " + n.to_s, + n] if player.blank? || player.lastplay < 1.hour.ago || player.key == cookies[:crib_id]
    end

    players << [log_out_wording, 0]
  end

  def render_hand(player_hand, player_screen, small_size = nil)
    small_size = Cribplayer.where(:game_id => player_screen.game_id).count > 2 if small_size.blank?
    if player_hand.present?
      ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "270px" : "400px", cards: Card.where(:position => "hand", :game_id => player_hand.game_id, :player_id => player_hand.id).order(:order).map{ |card| {:card => card.card, :id => card.id, :back => player_hand != player_screen} }, hand_type: "hand", small_size: small_size, player_hand: player_hand, player_screen: player_screen }
    else
      ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "270px" : "400px", cards: [], hand_type: "hand", small_size: small_size, player_hand: player_hand, player_screen: player_screen }
    end
  end

  def render_play(player_hand, player_screen, small_size = nil)
    small_size = Cribplayer.where(:game_id => player_screen.game_id).count > 2 if small_size.blank?
    if player_hand.present?
      if Card.where(:game_id => player_hand.game_id, :position => "cut").count > 0
        ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "270px" : "400px", cards: Card.where(:position => "cut", :game_id => player_hand.game_id, :player_id => player_hand.id).order(:order).map{ |card| {:card => card.card, :id => card.id, :back => false} }, hand_type: "cut", small_size: small_size, player_hand: player_hand, player_screen: player_screen }
      else
        ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "270px" : "400px", cards: Card.where(:position => [ "justplayed", "playopen",  "playturned"], :game_id => player_hand.game_id, :player_id => player_hand.id ).order(:order).map{|card| {:card => card.card, :id => card.id, :back => card.position == "playturned"}  }, hand_type: "play", small_size: small_size, player_hand: player_hand, player_screen: player_screen }
      end
    else
      ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "270px" : "400px", cards: [], hand_type: "play", small_size: small_size, player_hand: player_hand, player_screen: player_screen }
    end

  end

  def render_deck(player_screen, small_size = nil)
    small_size = Cribplayer.where(:game_id => player_screen.game_id).count > 2 if small_size.blank?
    card = Card.where(:position => "deckshow", :game_id => player_screen.game_id).first
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "190px" : "200px",  cards: [{:card => card.blank? ? 0 : card.card, :id => card.blank? ? 0 : card.id, :back => card.blank? } ], hand_type: "deck", small_size: small_size, player_screen: player_screen }
  end

  def render_crib(player_screen, small_size = nil)
    small_size = Cribplayer.where(:game_id => player_screen.game_id).count > 2 if small_size.blank?
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: small_size ? "230px" : "300px", cards: Card.where(:position => [ "crib", "cribopen" ], :game_id => player_screen.game_id ).order(:order).map{|card| {:card => card.card, :id => card.id, :back => card.position == "crib" }}, hand_type: "crib", small_size: small_size, player_screen: player_screen }
  end

  def render_name(player)
    ApplicationController.renderer.render partial: 'homepage/cribname', locals: {player: player }
  end

  def render_whosecrib(player)
    ApplicationController.renderer.render partial: 'homepage/whosecrib', locals: {player: player }
  end

  def render_hands_and_score(player)
    if player.ismobile
      ApplicationController.renderer.render(partial: 'homepage/hands_and_score_mobile', locals: {player: player })
    else
      ApplicationController.renderer.render(partial: 'homepage/hands_and_score', locals: {player: player })
    end

  end


  def player_name(player)
    player.blank? ? "Empty" : player.name.present? ? player.name : "Player " + player.number.to_s
  end

  def round_is_in_play(player)
    Card.where(:game_id => player.game_id, :position => "cribopen").count == 4
  end

  def game_is_in_play(player)

    game = Cribgame.where(:game_id => player.game_id).first
    game.present? && game.hasstarted
  end

  def get_number_of_players(game_id)
    #If the came has started, is the number of players with the game ID, if the game hasn't started, the number of players who have been active in the past [10] minutes
    cribgame = Cribgame.where(:game_id => game_id).first
    if cribgame.present?
      if cribgame.hasstarted
        Cribplayer.where(:game_id => game_id).count
      else
        Cribplayer.where(:game_id => game_id).where("lastplay >= ?", 10.minutes.ago).count
      end
    else
      0
    end
  end

  def get_reset_requests(game_id)
    Cribplayer.where(:game_id => game_id).where("resetrequest > ?", 10.minutes.ago).where.not(:resetrequest => nil)
  end

  def get_deal_request(game_id)
    Cribplayer.where(:game_id => game_id).where("redealrequest > ?", 10.minutes.ago).where.not(:redealrequest => nil).first
  end

  def round_over(game_id)
    Card.where(:game_id => game_id, :position => "cribopen").count >= 4
  end

  def render_reset_requests(game_id)
    number_of_players = get_number_of_players(game_id)
    player_requests = get_reset_requests(game_id)

    stg = ""
    if player_requests.count > 0
      stg += "Reset request"
      stg += "s" if player_requests.count > 1
      stg += " from: "
      flag = false
      player_requests.order(:resetrequest).each do |player|
        stg += "; " if flag
        stg += player_name(player)
        flag = true
      end
      stg += " " + player_requests.count.to_s + "/" + number_of_players.to_s
    end
    stg
  end

  def render_deal_request(game_id)
    player = get_deal_request(game_id)
    if player.present?
      "Deal request from: " +  player_name(player)
    else
      ""
    end
  end


  def scores_array(player)
    stg = ""

    Cribplayer.where(:game_id => player.game_id).order(:number).each do |player1|
      stg += ", " if !stg.blank?
      stg += player1.score.to_i.to_s
    end
    "[" + stg + "]"
  end

  def names_array(player)
    stg = ""

    Cribplayer.where(:game_id => player.game_id).order(:number).each do |player1|
      stg += ", " if !stg.blank?
      stg += "\"" + player_name(player1) + "\""
    end
    ("[" + stg + "]").html_safe
  end

  def can_cut(player)
    number_of_cut_cards = Card.where(:position => "cut", :game_id => player.game_id, :player_id => player.id).count
    Cribplayer.where(:game_id => player.game_id).each do |player1|
      return true if player1 != player && Card.where(:position => "cut", :game_id => player.game_id, :player_id => player1.id).count >= number_of_cut_cards
    end
    false
  end

  def first_to_play(player)
    if player.present?
      cribgame = Cribgame.where(:game_id => player.game_id).first
      if cribgame
        .present?
        if player.number == 1
          cribgame.whosecrib == Cribplayer.where(:game_id => player.game_id).count
        else
          cribgame.whosecrib == player.number - 1
        end
      end
    end
  end
end
