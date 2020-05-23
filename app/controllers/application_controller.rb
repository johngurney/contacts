class ApplicationController < ActionController::Base

  before_action :check_cookie_consent, except: [:cookie_consent, :log_in, :contact_sheet, :download_content, :get_picture, :position, :location, :video, :xmas, :xmas1, :xmas_q, :xmas_q_correct, :shops, :crib, :crib_move_card, :crib_reset, :crib_player, :crib_player_up, :crib_player_down, :crib_reset_players, :whosecrib ]
  before_action :check_logged_in, except: [:cookie_consent, :log_in, :contact_sheet, :download_content, :get_picture, :position, :location, :video, :xmas, :xmas1, :xmas_q, :xmas_q_correct, :shops, :crib, :crib_move_card, :crib_reset, :crib_player, :crib_reset_players, :crib_player_up, :crib_player_down, :whosecrib ]
  before_action :check_cookie_consent_shops, only: [:shops]
  before_action :crib_id, only: [:crib, :crib_player]

  def check_cookie_consent
    if cookies[:contacts_cookie_consent].blank?
      render 'general/cookie_consent'
      false
    end
  end

  def check_cookie_consent_shops
    if cookies[:shops_cookie].blank?
      render 'general/cookie_consent_shops'
      false
    end
  end

  def crib_id

    crib_id = cookies[:crib_id]
    if crib_id.blank?
      o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
      cookies.permanent[:crib_id] = (1..10).map { o[SecureRandom.random_number(o.length)] }.join
    end

    player = Cribplayer.where(:key => crib_id).first
    if player.present?
      player.lastplay = Time.now()
      player.save
    else
      player = Cribplayer.new
      player.key = cookies[:crib_id]
      player.save(validate: false)
    end

  end

  def check_logged_in
    if cookies.signed[:contacts_logged_in].blank?
      render 'general/password'
      false
    end
  end


  def telephone_link(tel_no)
      tel_no_mod = tel_no.to_s.scan(/(?:^\+)?\d+/)
      self.class.helpers.link_to tel_no, "#{tel_no_mod.join '-'}"
  end

  helper_method :telephone_link, :mobile?

  def mobile?
    require "browser/aliases"
    Browser::Base.include(Browser::Aliases)
    @browser = Browser.new(request.env["HTTP_USER_AGENT"])
    @browser.mobile? == true
  end

  def colors
    '["Maroon", "Brown", "Olive", "Teal", "Navy", "Black", "Red", "Orange"]'
  end

end
