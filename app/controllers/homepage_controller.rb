class HomepageController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:position]

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
    puts "test" + request.raw_post
    arry = request.raw_post.split(" ")

    log = Positionlog.create(:latitude => arry[1].to_d, :longitude => arry[2].to_d, :user_name => arry[3].to_s )
    log.save

    render :plain => "Ok"
  end

  def location
  end

  def location_log
  end

  def location_cheat_log_in
    cookies.permanent[:location_user] = params[:user]
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

end
