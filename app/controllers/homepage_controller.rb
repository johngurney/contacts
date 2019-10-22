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

    n = 0

    Following.where(:following_user_id => user_id).each do |following|
      position = Positionlog.where(:user_id => following.monitored_user_id).order(:created_at).last
      if position.present?
        a << {latitude: position.latitude + n * 0.001, longitude: position.longitude - n * 0.001, name: User.find(following.monitored_user_id).map_name}
      end
      n+= 1
    end
    puts "&&&" + a.to_s
    a = "" if a.blank?


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
    elsif  params[:user_id].to_i != 0
      user = User.find(params[:user_id])
      if cookies.permanent[:location_user_id] != params[:user_id]
        cookies.permanent[:location_user_id] = params[:user_id]
      else
        user.allow_monitoring = params[:allow_monitoring] == "1"
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
