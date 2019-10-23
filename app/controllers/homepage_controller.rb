class HomepageController < ApplicationController
  @@counter = 0
  skip_before_action :verify_authenticity_token, only: [:position]

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

    if arry[1] != "null"
      log = Positionlog.create(:latitude => arry[1].to_d, :longitude => arry[2].to_d, :user_id => user_id.to_s )
      log.save
    end

    a = []

    Following.where(:following_user_id => user_id).each do |following|
      position = Positionlog.where(:user_id => following.monitored_user_id).order(:created_at).last
      if position.present?
        trace = []
        if User.find(user_id).trace
          Positionlog.where(:user_id => following.monitored_user_id).order(:created_at).last(50).each do |log|
            trace << [log.latitude, log.longitude]
          end
        end
        a << {latitude: position.latitude, longitude: position.longitude, name: User.find(following.monitored_user_id).map_name,  trace: trace.to_json}
      end
    end

    a = "" if a.blank?

    puts a.to_s

    # render json: {:latitude => "1234", :longitude => "9876", :counter => @@counter}
    render json: a
    @@counter += 1

  end

  def location
    @@counter = 0
    user_id= cookies[:location_user_id].to_i
    @user = User.find(user_id) if user_id > 0 && User.where(:id == user_id).count > 0

    render "location", :layout => "location"

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



    elsif  params[:user_id].to_i != 0
      user = User.find(params[:user_id])
      if cookies.permanent[:location_user_id] != params[:user_id]
        cookies.permanent[:location_user_id] = params[:user_id]
      else
        user.allow_monitoring = params[:allow_monitoring] == "1"
        user.trace = params[:trace] == "1"
        user.update_frequency = params[:update_frequency].to_i
        user.last_posting_within = params[:last_posting_within].to_i
        user.save
        User.all.each do |user_mon|
          puts "+++" + user_mon.id.to_s
          if params["user" + user_mon.id.to_s] =="1"
            puts "***" + user_mon.id.to_s
            Following.create(:following_user_id => user.id, :monitored_user_id => user_mon.id) if Following.where(:following_user_id => user.id, :monitored_user_id => user_mon.id).count == 0
          else
            Following.where(:following_user_id => user.id, :monitored_user_id => user_mon.id).delete_all if Following.where(:following_user_id => user.id, :monitored_user_id => user_mon.id).count > 0
          end
        end
      end
    end

    redirect_to location_path
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
      puts stg
    end
    send_data image.to_blob, :filename => "stick_man.png", :type => "image/png"
  end


end
