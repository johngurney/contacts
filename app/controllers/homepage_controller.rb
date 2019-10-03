class HomepageController < ApplicationController
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


end
