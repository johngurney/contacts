class HomepageController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:position, :xmas_position, :crib_move_card, :crib_player_up, :crib_player_down, :crib_reset, :test]
  before_action :get_player, only: [:crib, :crib_player, :crib_move_card, :crib_reset, :test]

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

    # crib_shuffle_and_deal(@player) if Card.count == 0
    render "crib", :layout => false

  end

  def crib_shuffle_and_deal(player)

    game_id = player.game_id
    if game_id != ""

      crib_shuffle(game_id)

      number_of_players = helpers.get_number_of_players(game_id)

      number_of_cards_per_player = number_of_players == 2 ? 6 : 5

      (0...number_of_players).each do |player_number|
        (0...number_of_cards_per_player).each do |n|
          puts "^^" + player_number.to_s + "; " + n.to_s
          puts (player_number + number_of_players * n).to_s

          card = Card.where(:game_id => game_id, :position => "deck", :order => player_number + number_of_players * n ).first
          card.position = "hand"
          card.player_id = Cribplayer.where(:game_id  => game_id, :number => player_number + 1).first.id
          card.order = n
          card.save
        end
      end
      if number_of_players == 3
        card = Card.where(:game_id => game_id, :position => "deck", :order => 15 ).first
        card.position = "crib"
        card.save(validate: false)
      end

    end
  end

  def crib_shuffle(game_id)


    if game_id != ""
      if Card.where(:game_id => game_id).count != 52
        Card.where(:game_id => game_id).delete_all
        (0..51).each do |card|
          Card.create!(:card => card.to_s, :game_id => game_id,:order => SecureRandom.random_number(100000))
        end
      else
        Card.where(:game_id => game_id).all.each do |card|
          card.order =  SecureRandom.random_number(100000)
          card.save
        end
      end

      n=0
      Card.where(:game_id => game_id).order(:order).each do |card|
        card.order = n
        card.position = "deck"
        n += 1
        card.save(validate: false)
      end
    end
  end

  def crib_player

    send_all_cards_to_all_other_players_flag = false

    if params[:commit] == "Deal"

      cribgame = Cribgame.where(:game_id => @player.game_id).first

      if (cribgame.blank? || !cribgame.hasstarted) || (Cribplayer.where(:game_id => @player.game_id).where("redealrequest >= ?", 10.minutes.ago).where.not(:id => @player.id ).count > 0) || helpers.round_over(@player.game_id)

        shuffle_deal_and_send_to_other(@player)

        if cribgame.blank?
          cribgame = Cribgame.new
          cribgame.game_id = @player.game_id
          cribgame.save
        end


        if !cribgame.hasstarted
          Cribplayer.where(:game_id => @player.game_id).where("lastplay < ?", 10.minutes.ago).each do |player|
            player.game_id = ""
            player.save
          end
          cribgame.hasstarted = true
          cribgame.save
        end

      else

        @player.redealrequest = Time.now()
        @player.save

        Cribplayer.where(:game_id => @player.game_id).each do |player|
          ActionCable.server.broadcast 'room_channel' +  player.key, dealrequest: helpers.render_deal_request(player.game_id) if player != @player && player.key.present?
        end
      end

    elsif params[:commit] == "Apply"

      if @player.game_id != params[:game_id]
        players = Cribplayer.where(:game_id => params[:game_id])

        if players.present?


          if players.count >= 4
            #If already four or more players, get rid of any players from game who haven't played for four or more hours
            players.where('lastplay > ?', 4.hours.ago).order(:lastplay).all each do |player|
              player.game_id = ""
              player.save
            end
          end

        end

        cribgame = Cribgame.where(:game_id => params[:game_id]).first

        if cribgame.blank? || (!(cribgame.hasstarted || cribgame.freezenewplayers) && Cribplayer.where(:game_id => params[:game_id]).count < 4)
          #Add player to game
          @player.game_id = params[:game_id]
          make_new_crib_game(@player)
          @player.number = players.blank? ? 1 : players.maximum(:number) + 1
          send_all_cards_to_all_other_players_flag = true
        else
          render "homepage/currently_in_play", :layout => false
          return
        end


      end

      if @player.name != params[:name]
        send_name_to_all_other_players_flag = true
        @player.name = params[:name]
      end

      @player.lastplay = Time.now()
      @player.save

    end

    send_hands_and_scores_to_other_players(@player) if send_all_cards_to_all_other_players_flag

    redirect_to crib_path
    # render "homepage/cardtest", :layout => false
  end



  def shuffle_deal_and_send_to_other(player)

    crib_shuffle_and_deal(player)

    Cribplayer.where(:game_id => player.game_id).each do |player_screen|
      player_screen.redealrequest = nil
      player_screen.save
    end

    Cribplayer.where(:game_id => player.game_id).each do |player_screen|
      if player != player_screen
        player_screen_key = player_screen.key
        if player_screen_key.present?
          Cribplayer.where(:game_id => player.game_id).each do |player_hand|
            ActionCable.server.broadcast 'room_channel' +  player_screen_key, hand_command(player_hand) => helpers.render_hand(player_hand, player_screen)
            ActionCable.server.broadcast 'room_channel' +  player_screen_key, play_command(player_hand) => helpers.render_play(player_hand, player_screen)
          end
          ActionCable.server.broadcast 'room_channel' +  player_screen_key, deck: helpers.render_deck(player_screen)
          ActionCable.server.broadcast 'room_channel' +  player_screen_key, crib: helpers.render_crib(player_screen)
          ActionCable.server.broadcast 'room_channel' + player_screen_key, dealrequest: helpers.render_deal_request(player.game_id)
          # ActionCable.server.broadcast 'room_channel' +  player_screen_key, dealrequest: helpers.render_redealrequest(player_screen)
        end
      end
    end
  end


  def crib_move_card

    number_of_players = 2

    r  = request.raw_post.split("_")
    instruction = r[0]
    data = r[1]

    if @player.present?
      @player.lastplay = Time.now()
      @player.save
    end
    puts "instruction" + instruction

    case instruction



    when "l"
      card = Card.find(data.to_i)
      if card.order > 0
        card1 = Card.where(:position => "hand", :player_id => card.player_id, :order => card.order - 1).first
        card.order -= 1
        card.save
        card1.order += 1
        card1.save
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], "player" + @player.number.to_s + "_hand" => helpers.render_hand(@player, @player)
      end

    when "r"
      card = Card.find(data.to_i)
      if card.order < 5
        card1 = Card.where(:position => "hand", :player_id => card.player_id, :order => card.order + 1).first
        card.order += 1
        card.save
        card1.order -= 1
        card1.save
        ActionCable.server.broadcast 'room_channel' + cookies[:crib_id], "player" + @player.number.to_s + "_hand" => helpers.render_hand(@player, @player)
      end

    when "p"
      card = Card.find(data.to_i)

      Card.where(:position => ["justplayed"], :game_id => card.game_id).each do |card|
        card.position = "playopen"
        card.save
      end

      card.position = "justplayed"
      m = Card.where(:position => ["playopen", "playturned"], :game_id => card.game_id, :player_id => card.player_id ).maximum(:order)
      card.order = m.blank? ? 0 : m + 1
      card.save

      Cribplayer.where(:game_id => card.game_id).each do |player|
        player_key = player.key
        if player_key.present?
          ActionCable.server.broadcast 'room_channel' + player_key, hand_command(@player) => helpers.render_hand(@player, player)
          ActionCable.server.broadcast 'room_channel' + player_key, play_command(@player) => helpers.render_play(@player, player)
          ActionCable.server.broadcast 'room_channel' + player_key, play_command(player) => helpers.render_play(player, player) if @player != player #To update justplayed
          ActionCable.server.broadcast 'room_channel' + other_key, crib: helpers.render_crib(player) if Card.where(:position => ["playopen", "playturned"] ).count >= 8
        end
      end


    when "c"
      card = Card.find(data.to_i)

      card.position = "crib"
      card.save

      Cribplayer.where(:game_id => card.game_id).each do |player|
        player_key = player.key
        if player_key.present?
          ActionCable.server.broadcast 'room_channel' + player_key, hand_command(@player) => helpers.render_hand(@player, player)
          ActionCable.server.broadcast 'room_channel' + player_key, crib: helpers.render_crib(player)
          ActionCable.server.broadcast 'room_channel' + player_key, deck: helpers.render_deck(player) if Card.where(:game_id => card.game_id, :position => "crib").count >= 4
        end
      end

    when "t"

      card = Card.find(data.to_i)

      positions = [ "justplayed", "playturned", "playopen" ]

      number_of_cards_in_play = Card.where(:position => positions, :game_id => card.game_id, :player_id => card.player_id ).count

      puts "number_of_cards_in_play" + number_of_cards_in_play.to_s

      player_over = Card.where(:position => "hand", :game_id => card.game_id).count == 0

      Card.where(:position => positions, :game_id => card.game_id, :player_id => card.player_id ).each do |card|
        card.position = player_over ? "playopen" : "playturned"
        card.save
      end

      player_hand = Cribplayer.find(card.player_id)

      Cribplayer.where(:game_id => card.game_id).each do |player|
        player_key = player.key
        if player_key.present?
          ActionCable.server.broadcast 'room_channel' + player_key, play_command(player_hand) => helpers.render_play(player_hand, player)
        end
      end


    when "d"
      #Turn over the top card from the deck (at the start of the round)

      game_id = @player.game_id

      if Card.where(:position => "deckshow", :game_id => game_id).count == 0
        card = Card.where(:position => "deck", :game_id => game_id).order(:order).first
        card.position = "deckshow"
        card.save

        Cribplayer.where(:game_id => game_id).each do |player|
          player_key = player.key
          if player_key.present?
            ActionCable.server.broadcast 'room_channel' + player_key , deck: helpers.render_deck(player)
            ActionCable.server.broadcast 'room_channel' + player_key, hand_command(player) => helpers.render_hand(player, player)  #NB to refresh dropdowns
            ActionCable.server.broadcast 'room_channel' + player_key, crib: helpers.render_crib(player)  #NB to refresh dropdowns
          end
        end


      end

    when "o"

      #Turn over the crib (at the end of the round)

      game_id = @player.game_id

      Card.where(:position => "crib", :game_id => game_id).each do |card|
        card.position = "cribopen"
        card.save
      end

      Cribplayer.where(:game_id => game_id).each do |player|
        player_key = player.key
        if player_key.present?
          ActionCable.server.broadcast 'room_channel' + player_key, crib: helpers.render_crib(player)
        end
      end

    when "p1","p2","p3","p4"

        values = data.split("/")
        key = values[0]

        game_id = @player.game_id

        score_add = values[1].to_i
        player = Cribplayer.where(:game_id => game_id , :number => instruction[1, 1].to_i).first
        player.score = player.score.to_i + score_add
        player.score = 0 if player.score < 0
        player.save
        send_scores(game_id)


      when "s1","s2","s3","s4"
        values = data.split("/")
        key = values[0]

        game_id = @player.game_id

        score = values[1].to_i
        player = Cribplayer.where(:game_id => game_id , :number => instruction[1, 1].to_i).first
        player.score = score
        player.save

        send_scores(game_id)


      when "cut"

        if Card.where(:player_id => @player.id, :position =>"cut").count == 0
          loop do
            n = SecureRandom.random_number(52)
            card = Card.where(:game_id => @player.game_id, :order => n).first
            break if card.position == "deck"
          end
          card.position = "cut"
          card.player_id = @player.id
          card.save

          small_size = (Cribplayer.where(:game_id => @player.game_id).count > 2)

          Cribplayer.where(:game_id => @player.game_id).each do |player|
            player_key = player.key
            ActionCable.server.broadcast 'room_channel' +  player.key, play_command(@player) => helpers.render_play(@player, player, small_size) if player.key.present?
          end
          ActionCable.server.broadcast 'room_channel' +  @player.key, deck: helpers.render_deck(@player, small_size)
        end

      when "retcrib"

        card = Card.find(data.to_i)
        card.position = "hand"
        card.save

        small_size = (Cribplayer.where(:game_id => @player.game_id).count > 2)
        Cribplayer.where(:game_id => card.game_id).each do |player|
          player_key = player.key
          if player.key.present?
            ActionCable.server.broadcast 'room_channel' +  player.key, hand_command(@player) => helpers.render_hand(@player, player, small_size)
            ActionCable.server.broadcast 'room_channel' +  player.key, crib: helpers.render_crib(player, small_size)
          end
        end

      when "retplay"


        card = Card.find(data.to_i)
        card.position = "hand"
        card.save

        small_size = (Cribplayer.where(:game_id => @player.game_id).count > 2)
        Cribplayer.where(:game_id => card.game_id).each do |player|
          player_key = player.key
          if player.key.present?
            ActionCable.server.broadcast 'room_channel' +  player.key, hand_command(@player) => helpers.render_hand(@player, player, small_size)
            ActionCable.server.broadcast 'room_channel' +  player.key, play_command(@player) => helpers.render_play(@player, player, small_size)
          end
        end
    end

  end

  def crib_player_up
    player_id = params[:player_id].to_i
    if player_id > 0
      player = Cribplayer.find(player_id)
      player1 = Cribplayer.where(:game_id => player.game_id, :number => player.number + 1).first
      player.number +=1
      player1.number -=1
      player.save
      player1.save
      send_hands_and_scores_to_other_players(player)
    end

    redirect_to crib_path
  end

  def crib_player_down
    player_id = params[:player_id].to_i
    if player_id > 0
      player = Cribplayer.find(player_id)
      player1 = Cribplayer.where(:game_id => player.game_id, :number => player.number - 1).first
      player.number -=1
      player1.number +=1
      player.save
      player1.save
      send_hands_and_scores_to_other_players(player)
    end

    redirect_to crib_path
  end

  def crib_reset

    @player.resetrequest = Time.now()
    @player.save


    if helpers.get_reset_requests(@player.game_id).count == helpers.get_number_of_players(@player.game_id)

      crib_shuffle(@player.game_id)

      Cribplayer.where(:game_id => @player.game_id).each do |player|
        player.resetrequest = nil
        player.score = 0
        player.save
      end

      game = Cribgame.where(:game_id => @player.game_id).first
      if game.present?
        game.hasstarted = false
        game.save
      end
    end

    Cribplayer.where(:game_id => @player.game_id).each do |player|
      if @player != player
        player_key = player.key
        if player.key.present?
          ActionCable.server.broadcast 'room_channel' +  player.key, reset_requests: helpers.render_reset_requests(player.game_id)
        end
      end
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

  def crib_reset_players

    crib_shuffle(@player.game_id)
    Cribplayer.where(:game_id => @player.game_id).each do |player|
      player.score = 0
      player.save_action
    end
    game = Cribgame.where(:game_id => @player.game_id).first
    if game.present?
      game.hasstarted = false
      game.save
    end

    redirect_to crib_path

  end

  def get_player
    @player = Cribplayer.where(:key => cookies[:crib_id]).first
  end

  def hand_command(player)
    "player" + player.number.to_s + "_hand"
  end

  def play_command(player)
    "player" + player.number.to_s + "_play"
  end

  def make_new_crib_game(player)

    cribgame = Cribgame.where(:game_id => player.game_id).first
    if cribgame.blank?
      cribgame = Cribgame.new
      cribgame.game_id = player.game_id
      cribgame.hasstarted = false
      cribgame.save
      crib_shuffle(player.game_id)
    end

  end

  def send_scores(game_id)
    scores = Cribplayer.where(:game_id => game_id).order(:number).map{ |player| player.score.to_i.to_s }
    names = Cribplayer.where(:game_id => game_id).order(:number).map{ |player| helpers.player_name(player) }

    Cribplayer.where(:game_id => game_id).each do |player|
      player_key = player.key
      if player_key.present?
        ActionCable.server.broadcast 'room_channel' + player_key, scores: scores, names: names, player_number: player.number
      end
    end
  end

  def send_hands_and_scores_to_other_players(player)
    scores = Cribplayer.where(:game_id => player.game_id).order(:number).map{ |player1| player1.score.to_i.to_s }
    names = Cribplayer.where(:game_id => player.game_id).order(:number).map{ |player1| helpers.player_name(player1) }

    Cribplayer.where(:game_id => player.game_id).each do |player1|
      if player != player1 || true
        key = player1.key
        if key.present?
          ActionCable.server.broadcast 'room_channel' +  key, hands_and_score: helpers.render_hands_and_score(player1), scores: scores, names: names, player_number: player1.number

        end
      end
    end

  end

  def test

    send_scores(@player.game_id)
    render "homepage/cardtest", :layout => false

  end


end
