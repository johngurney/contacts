class HomepageController < ApplicationController
  @@counter = 0
  skip_before_action :verify_authenticity_token, only: [:position, :xmas_position]

  def homepage
    @@counter = 0
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
      @question = "Q1.  What is the colour of the front door at number 35?"
      @answer1 = "Red"
      @answer2 = "Yellow"
      @answer3 = "Blue"
      @a = 2
      @ne = "51.5401, -0.1076"
      @sw = "51.53915, -0.1089"
      render "xmas_q", :layout => false

  elsif log.stage == 2

      @next_q = 3
      @ordinal = "second"
      @question = "Q2.  What is the name of the villas at numbers 23 and 25?"
      @answer1 = "Devonshire"
      @answer2 = "Cornwall"
      @answer3 = "Somerset"
      @a = 1
      @ne = "51.5418, -0.1093"
      @sw = "51.54095, -0.11"

      render "xmas_q", :layout => false

    elsif log.stage == 3

      @next_q = 4
      @ordinal = "third"
      @question = "Q3.  How many circles are above the door at number 1?"
      @answer2 = "Two"
      @answer1 = "Four"
      @answer3 = "Five"
      @a = 3
      @ne = "51.53927, -0.10985"
      @sw = "51.53895, -0.111"

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
      @ne = "51.5389, -0.1083"
      @sw = "51.53862, -0.109"

      render "xmas_q", :layout => false

    elsif log.stage == 99

      render "video", :layout => false

    end


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

      puts "last_posting_value = " + last_posting_value.to_s

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
      puts user.to_s
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
  end



end
