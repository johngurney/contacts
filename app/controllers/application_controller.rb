class ApplicationController < ActionController::Base
  def telephone_link(tel_no)
      tel_no_mod = tel_no.to_s.scan(/(?:^\+)?\d+/)
      self.class.helpers.link_to tel_no, "#{tel_no_mod.join '-'}"
  end

  helper_method :telephone_link

  def mobile?
    require "browser/aliases"
    Browser::Base.include(Browser::Aliases)
    @browser = Browser.new(request.env["HTTP_USER_AGENT"])
    @browser.mobile?
  end

end
