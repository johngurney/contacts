class HomepageController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:position, :xmas_position, :crib_move_card]

  def homepage

  end

  def add_contact
    contact = Contact.new
    contact.first_name = "Dan"
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    contact.last_name = (0...16).map { o[SecureRandom.random_number(o.length)] }.join

    contact.save
    redirect_to root_path
  end

  def set_token

    if cookies[:xmas_token].blank?
      o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
      token = (0...16).map { o[SecureRandom.random_number(o.length)] }.join
      cookies.permanent[:xmas_token] = token
      XmasUser.create(:token => token, :stage => 0)
    end
  end

  def xmas
    set_token
    log = XmasUser.where(:token => cookies[:xmas_token]).first
    log.update(:stage => 1) if log.present?
    render "xmas", :layout => false
  end

  def xmas_q_correct
    set_token
    log = XmasUser.where(:token => cookies[:xmas_token]).first
    log.update(:stage => params[:id].to_s) if log.present?
    redirect_to xmas_q_path
  end

  def xmas_q

    set_token
    log = XmasUser.where(:token => cookies[:xmas_token]).first

   if log.blank? || log.stage == 1

      @next_q = 2
      @ordinal = "first"
      @question = "Q1.  In Barnsbury Sq there is a brick building with a noticeboard.  What time is the \"volunteer gardening\"?"
      @answer1 = "10am to 11am Saturdays"
      @answer2 = "3pm to 4pm Sundays"
      @answer3 = "12pm to 1pm Wednesdays"
      @a = 1
      @ne = "51.5423, -0.1095"
      @sw = "51.54145, -0.1118"
      render "xmas_q", :layout => false

  elsif log.stage == 2

      @next_q = 3
      @ordinal = "second"
      @question = "Q2. What is the name of number 4 Ripplevale Grove? "
      @answer1 = "Caldeonian Cottage"
      @answer2 = "Albion Cottage"
      @answer3 = "Hibernian Cottage"
      @a = 2
      @ne = "51.5402, -0.1092"
      @sw = "51.5395, -0.1113"

      render "xmas_q", :layout => false

    elsif log.stage == 3

      @next_q = 4
      @ordinal = "third"
      @question = "Q3.  What are the opening times of \"Angels Corner Mini Market\" on Fridays and Saturdays?"
      @answer1 = "8am to 11pm"
      @answer2 = "7am to 10pm"
      @answer3 = "7am to 11pm"
      @a = 1
      @ne = "51.536, -0.109"
      @sw = "51.535, -0.11"

      render "xmas_q", :layout => false

    elsif log.stage == 4

      #Richmond Avenue

      @next_q = 99
      @ordinal = ""
      @question = ""
      @answer2 = ""
      @answer1 = ""
      @answer3 = ""
      @a = 0
      @ne = "51.848, -1.3556"
      @sw = "51.8472, -1.3575"

      render "xmas_q", :layout => false

    elsif log.stage == 99

      render "video", :layout => false

    end


  end

  def xmas_test
    render "video", :layout => false
  end

  def cookie_consent

    cookies.permanent[:contacts_cookie_consent] = true if params[:cookie_consent] == "1"
    redirect_to root_path
  end

  def log_in
    cookies.permanent.signed[:contacts_logged_in] = true if params[:password] == Rails.configuration.system_password
    redirect_to root_path
  end

  def reset_cookie_consent

    cookies.permanent[:contacts_cookie_consent] = nil

    redirect_to root_path
  end

  def log_out

    cookies.permanent[:logged_in] = nil

    redirect_to root_path
  end

  def test

    prng = Random.new
    (1..1000).each do |n|
      log = Log.create(:sheet_id => 3, :ip_address => "123")
      log.created_at = 7.months.ago - prng.rand(100).days
      log.save
    end


    redirect_to root_path
  end

  def position

    arry = request.raw_post.split(" ")
    user_id = arry[3].to_i

    usergroup_id = arry[4].to_i
    positions = []

    if user_id > 0

      user = User.find(user_id)

      if arry[1] != "null"
        log = Positionlog.create(:latitude => arry[1].to_d, :longitude => arry[2].to_d, :user_id => user_id.to_s )
        log.save
      end

      last_posting_value = helpers.last_posting_values(user.last_posting_within)[0]

      Following.where(:following_user_id => user_id, :usergroup_id => usergroup_id).each do |following|

        if last_posting_value == 0
          logs = Positionlog.where(:user_id => following.monitored_user_id).order(:created_at).last(30)
        else
          logs = Positionlog.where(:user_id => following.monitored_user_id).where("created_at >= ?", last_posting_value.seconds.ago).order(:created_at).last(30)
        end
        position = logs.last
        if position.present?
          trace = []
          if user.trace
            logs.each do |log|
              trace << [log.latitude, log.longitude]
            end
          end
          t = logs.last.created_at
          stg = User.find(following.monitored_user_id).map_name + " (at " + t.in_time_zone(user.time_zone).strftime("%H:%M:%S on %e %b %Y") + "; " + helpers.time_ago_in_words(t) + " ago); "
          positions << {latitude: position.latitude, longitude: position.longitude, name: User.find(following.monitored_user_id).map_name,  trace: trace.to_json, text: stg}
        end
      end
    end

    if positions.blank?
      render json: ""
    else
      render json: {positions: positions}
    end

  end



  def xmas_position

    arry = request.raw_post.split(" ")
    token = arry[3]


    user = XmasUser.where(:token => token).first
    if user.present?
      user.latitude = arry[1].to_d
      user.longitude = arry[2].to_d
      user.save
    end


    render json: ""

  end




  def xmas_monitor

    user = XmasUser.order(:updated_at).last


    if user.blank? || user.stage == 1

       @ne = "51.5401, -0.1076"
       @sw = "51.53915, -0.1089"

    elsif user.stage == 2

       @ne = "51.5418, -0.1093"
       @sw = "51.54095, -0.11"

    elsif user.stage == 3

       @ne = "51.53927, -0.10985"
       @sw = "51.53895, -0.111"

    else

       @ne = "51.5389, -0.1083"
       @sw = "51.53862, -0.109"
     end

    @latitude = user.latitude
    @longitude = user.longitude

    # @latitude = 51.53926
    # @longitude = -0.1087

    render "xmas_monitor", :layout => false
  end






  def catch_all

    @usergroup = Usergroup.where('lower(url) = ?', request.original_fullpath.tr("\\\/","")).first

    if @usergroup.blank?
      redirect_to root_path
    else

      if cookies[:location_user_id].present?
        user_id = cookies[:location_user_id].to_i
        if @usergroup.users.include?(User.find(user_id))
          @user = User.find(user_id) if user_id > 0 && User.where(:id == user_id).count > 0
        else
          user_id = nil
        end
      end

      render "location", :layout => "location"
    end
  end


  def location
    redirect_to users_path
  end

  def location_log
  end

  def location_controls
    if  params[:commit] == "Set up users"
      User.delete_all
      User.create(:name => "Gabriella")
      User.create(:name => "Dan")
      User.create(:name => "Adele")
      User.create(:name => "Guy")

    elsif  params[:commit] == "Set paths"
      Positionlog.delete_all

      latitude_north = 51.544328
      latitude_south = 51.536808
      longitude_west = -0.116385
      longitude_east = -0.106652

      latitude_height = latitude_north - latitude_south
      longitude_width  = longitude_east - longitude_west

      # gaby = [[0.1,0.1], [0.3,0.1]]
      gaby = [[0.87,0.14], [0.84, 0.05], [0.7,0.12], [0.61742,0.120826], [0.607845745, 0.148053016], [0.597606383, 0.1665468], [0.577659574, 0.183088462], [0.538829787, 0.186273503], [0.535239362, 0.296208774], [0.428058511, 0.291174355], [0.421808511, 0.510942156], [0.421409574, 0.557279359], [0.396143617, 0.701119901], [0.310106383, 0.673584712], [0.258643617, 0.663104901], [0.251595745, 0.676358779], [0.263164894, 0.774992294]]
      gaby.each do |coordinate|
        latitude = latitude_south + latitude_height * coordinate[0]
        longitude = longitude_west + longitude_width * coordinate[1]
        Positionlog.create(:latitude => latitude, :longitude => longitude, :user_id => User.where(:name => "Gabriella").first.id)
      end

    elsif  params[:commit] == "Admin"
      redirect_to users_path
      return

    elsif  params[:user_id].to_i != 0
      user = User.find(params[:user_id])
      usergroup = Usergroup.find(params[:id])
      if cookies.permanent[:location_user_id] != params[:user_id]
        cookies.permanent[:location_user_id] = params[:user_id]
      else
        user.allow_monitoring = params[:allow_monitoring] == "1"
        user.trace = params[:trace] == "1"
        user.update_frequency = params[:update_frequency].to_i
        user.last_posting_within = params[:last_posting_within].to_i
        user.time_zone = params[:time_zone]
        user.save
        User.all.each do |user_mon|
          if params["user" + user_mon.id.to_s] =="1"
            Following.create(:usergroup_id => usergroup.id, :following_user_id => user.id, :monitored_user_id => user_mon.id) if Following.where(:following_user_id => user.id, :monitored_user_id => user_mon.id, :usergroup_id => usergroup.id).count == 0
          else
            Following.where(:usergroup_id => usergroup.id, :following_user_id => user.id, :monitored_user_id => user_mon.id).delete_all
          end
        end
      end
    else
      cookies.permanent[:location_user_id] = nil
    end

    redirect_to "/" + Usergroup.find(params[:id].to_i).url #location_path
  end

  def clear_all_location_logs
    Positionlog.delete_all
    redirect_to location_log_path
  end

  def download_location_logs
    stg = ""
    Positionlog.all.order(:created_at).each do |log|
      stg += log.user_name  + "\t" + log.created_at.to_s  + "\t" + log.longitude.to_s + "\t" + log.latitude.to_s + "\r\n"
    end
    send_data stg, :filename => "logs.txt" # , :type => "application/pdf"

  end


  def stick_man
    filename = Rails.root.join("public", "stick_man1.png").to_s
    image = MiniMagick::Image.open(filename )
    pixels = image.get_pixels
    for n1 in 0...image.height
      stg = ""
      for n2 in 0...image.width
        stg += pixels[n2][n1][0].to_s + " "
      end
    end
    send_data image.to_blob, :filename => "stick_man.png", :type => "image/png"
  end

  def video
    render "video", :layout => false
  end

  def xmas_eve_video
    render "xmas_eve_video", :layout => false
  end

  def shops
    render "shops", :layout => false
  end

  def shop_select
    d = -1
    (0..4).each do |d1|
       if params["c" + d1.to_s].present?
         d = d1
         break
       end
    end
    if d >=0
      dte = Date.parse(params[:date]) + d.days
      Shopvisit.where(:user => cookies[:shops_cookie], :visitdate => dte).delete_all

    else

      h = 0
      d = 0
      (0..23).each do |h1|
        (0..4).each do |d1|
           if params["s" + d1.to_s + "_" + h1.to_s].present?
             h = h1
             d = d1
             break
           end
        end
      end
      dte = Date.parse(params[:date]) + d.days

      Shopvisit.where(:user => cookies[:shops_cookie], :visitdate => dte).delete_all
      Shopvisit.create(:user => cookies[:shops_cookie], :visitdate => dte, :visit_time => h)
    end
    redirect_to shops_path

  end

  def shops_cookie_consent

    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    cookies.permanent[:shops_cookie] = (0...16).map { o[SecureRandom.random_number(o.length)] }.join if params[:cookie_consent] == "1"
    redirect_to shops_path

  end

  def crib

    crib_shuffle_and_deal if Card.count == 0

    render "crib", :layout => false
  end

  def crib_shuffle_and_deal
    if Card.count != 52
      Card.delete_all
      (0..51).each do |card|
        Card.create(:card => card.to_s, :order => SecureRandom.random_number(100000))
      end
    else
      Card.all.each do |card|
        card.order =  SecureRandom.random_number(100000)
        card.save
      end

    end

    n=0
    Card.order(:order).each do |card|
      card.order = n
      card.position = "deck"
      n += 1
      card.save
    end

    (0..5).each do |n|
      card = Card.where(:order => n * 2).first
      card.position = "hand"
      card.player = 1
      card.order = n
      card.save

      card = Card.where(:order => n * 2 + 1).first
      card.position = "hand"
      card.player = 2
      card.order = n
      card.save
    end
  end

  def crib_player

    if params[:commit] == "Deal"
      shuffle_deal_and_send_to_other if Cribplayer.all.count >= 2 && Cribplayer.where(:number => 1).count >=1 && Cribplayer.where(:number => 2).count  >=1

    else

      if params[:player] != "0"
        player = Cribplayer.where(:key => cookies[:crib_id]).first
        if player.blank?
          Cribplayer.where(:number => params[:player].to_i).delete_all
          player = Cribplayer.new
          player.key = cookies[:crib_id]
        end
        player.number = params[:player].to_i
        player.lastplay = Time.now()
        player.save

      else
        Cribplayer.where(:key => cookies[:crib_id]).delete_all
      end

    end

    redirect_to crib_path
  end

  def shuffle_deal_and_send_to_other

    crib_shuffle_and_deal

    if Cribplayer.where(:key => cookies[:crib_id]).first.number == 1
      player = 1
      other_player = 2
    else
      player = 2
      other_player = 1
    end

    other = other_key

    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", your_hand: render_hand(other_player)
    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", other_hand: render_other_hand(player)
    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", your_play: render_play(other_player)
    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", other_play: render_play(player)
    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", deck: render_deck
    ActionCable.server.broadcast 'room_channel' + other, action: "update_hand", crib: render_crib
  end

  def render_hand(player)
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: "400px", cards: Card.where(:position => "hand", :player => player).order(:order).map{ |card| {:card => card.card, :back => false} }, hand_type: "hand", player: player }
  end

  def render_other_hand(player)
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: "400px", cards: Card.where(:position =>  "hand", :player => player ).map{|card| {:card => card.card, :back => true }  }, hand_type: "hand", player: player }
  end

  def render_play(player)
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: "400px", cards: Card.where(:position => [ "playopen",  "playturned"], :player => player ).order(:order).map{|card| {:card => card.card.to_i, :back => card.position != "playopen"}  }, hand_type: "play", player: player }
  end

  def render_deck
    card = Card.where(:position => "deckshow").first
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: "400px", cards: [{:card => card.blank? ? 0 : card.card, :back => card.blank? } ], hand_type: "deck" }
  end

  def render_crib
    ApplicationController.renderer.render partial: 'homepage/hand', locals: {wdth: "400px", cards: Card.where(:position => [ "crib", "cribopen" ] ).order(:order).map{|card| {:card => card.card, :back => card.position == "crib" }}, hand_type: "crib" }
  end

  def crib_move_card

    r  = request.raw_post.split("_")
    instruction = r[0]
    card_number = r[1]

    player = Cribplayer.where(:key => cookies[:crib_id]).first
    if player.present?
      player.lastplay = Date.new()
      player.save
    end


    case instruction

    when "l"
      card = Card.where(:card => card_number).first
      if card.order > 0
        card1 = Card.where(:position => "hand", :player => card.player, :order => card.order - 1).first
        card.order -= 1
        card.save
        card1.order += 1
        card1.save
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", your_hand: render_hand(card.player), hand_type: "hand"
      end

    when "r"
      card = Card.where(:card => card_number).first
      if card.order < 5
        card1 = Card.where(:position  => "hand", :player => card.player, :order => card.order + 1).first
        card.order += 1
        card.save
        card1.order -= 1
        card1.save
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", your_hand: render_hand(card.player), hand_type: "hand"
      end

    when "p"
      card = Card.where(:card => card_number).first
      card.position = "playopen"
      m = Card.where(:position => ["playopen", "playturned"], :player => card.player ).maximum(:order)
      card.order = m.blank? ? 0 : m + 1
      card.save

      ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", your_hand: render_hand(card.player)
      ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", your_play: render_play(card.player)
      ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", other_hand: render_other_hand(card.player)
      ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", other_play: render_play(card.player)

      if Card.where(:position => ["playopen", "playturned"] ).count >= 8
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", crib: render_crib
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", crib: render_crib
      end

    when "c"
      card = Card.where(:card => card_number).first

      player =  card.player

      card.position = "crib"
      card.save

      ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", your_hand: render_hand(player), hand_type: "hand"
      ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", other_hand: render_other_hand(player), hand_type: "hand"
      ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", crib: render_crib
      ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", crib: render_crib

      if Card.where(:position => "crib").count >= 4
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", deck: render_deck
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", deck: render_deck
      end

    when "t"

      card = Card.where(:card => card_number).first

      positions = [ "playturned", "playopen" ]

      number_of_cards_in_play = Card.where(:position => positions, :player => card.player ).count

      Card.where(:position => positions, :player => card.player ).each do |card|
        card.position = number_of_cards_in_play == 4 ? "playopen" : "playturned"
        card.save
      end

      ActionCable.server.broadcast 'room_channel' + Cribplayer.where(:number => card.player ).first.key, action: "update_hand", your_play: render_play(card.player)
      ActionCable.server.broadcast 'room_channel' + Cribplayer.where(:number => 3 - card.player ).first.key, action: "update_hand", other_play: render_play(card.player)

    when "d"
      if Card.where(:position => "deckshow").count == 0
        card = Card.where(:position => "deck").order(:order).first
        card.position = "deckshow"
        card.save
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", deck: render_deck
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", deck: render_deck

        #NB update hands so that "play" drop down enabled
        (1..2).each do |player|
          ActionCable.server.broadcast 'room_channel' + Cribplayer.where(:number => player).first.key, action: "update_hand", your_hand: render_hand(player)
        end

      end

    when "o"
      Card.where(:position => "crib").each do |card|
        card.position = "cribopen"
        card.save
      end
      ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", crib: render_crib
      ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", crib: render_crib

      when "p1"
        player = Cribplayer.where(:number => 1).first
        player.score = player.score.to_i + card_number.to_i
        player.score = 0 if player.score < 0
        player.save
        scores = [Cribplayer.where(:number => 1).first.score.to_i, Cribplayer.where(:number => 2).first.score.to_i]
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", scores: scores
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", scores: scores

      when "p2"
        player = Cribplayer.where(:number => 2).first
        player.score = player.score.to_i + card_number.to_i
        player.score = 0 if player.score < 0
        player.save
        scores = [Cribplayer.where(:number => 1).first.score.to_i, Cribplayer.where(:number => 2).first.score.to_i]
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", scores: scores
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", scores: scores

      when "s1"
        player = Cribplayer.where(:number => 1).first
        player.score = change_score(player.score, card_number.to_i)
        player.save
        scores = [Cribplayer.where(:number => 1).first.score.to_i, Cribplayer.where(:number => 2).first.score.to_i]
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", scores: scores
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", scores: scores

      when "s2"
        player = Cribplayer.where(:number => 2).first
        player.score = change_score(player.score, card_number.to_i)
        player.save
        scores = [Cribplayer.where(:number => 1).first.score.to_i, Cribplayer.where(:number => 2).first.score.to_i]
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], action: "update_hand", scores: scores
        ActionCable.server.broadcast 'room_channel' + other_key, action: "update_hand", scores: scores
    end

  end

  def crib_reset
    shuffle_deal_and_send_to_other
    Cribplayer.all.each do |player|
      player.score = 0
      player.save
    end
    redirect_to crib_path
  end

  def change_score(oldscore, newscore)
    if oldscore < 30
      newscore
    elsif oldscore < 60
      newscore > 15 ? newscore : newscore + 60
    elsif oldscore < 90
      newscore <= 45 ? newscore + 60 : newscore
    else
      newscore + 60
    end
  end

  def other_key
    Cribplayer.where(:key => cookies[:crib_id]).first.number == 1 ? Cribplayer.where(:number => 2).first.key : Cribplayer.where(:number => 1).first.key

  end



end
