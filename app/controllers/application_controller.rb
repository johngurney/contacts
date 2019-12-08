class ApplicationController < ActionController::Base

  before_action :check_cookie_consent, except: [:cookie_consent, :log_in, :contact_sheet, :download_content, :get_picture, :position, :location, :video, :xmas, :xmas1, :xmas_q, :xmas_q_correct ]
  before_action :check_logged_in, except: [:cookie_consent, :log_in, :contact_sheet, :download_content, :get_picture, :position, :location, :video, :xmas, :xmas1. :xmas_q, :xmas_q_correct]

  def check_cookie_consent
    if cookies[:contacts_cookie_consent].blank?
      render 'general/cookie_consent'
      false
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
    @browser.mobile?
  end

  def colors
    '["Maroon", "Brown", "Olive", "Teal", "Navy", "Black", "Red", "Orange"]'
  end

end
