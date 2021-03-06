require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Contacts
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths << Rails.root.join('lib')

    config.system_password = "elephants"

    #This code just renders on startup the ext lowercase on all movie files in assets/images

    filename1 = Rails.root.join('app', 'assets', 'images','*.mov')
    Dir.glob(filename1, File::FNM_CASEFOLD).each do |filename1|
      ext = File.extname(filename1)
      filename2 = File.dirname(filename1) + "/" + File.basename(filename1).gsub(ext, "") + ext.downcase
      File.rename(filename1, filename2)
    end

    filename1 = Rails.root.join('app', 'assets', 'images','*.mp4')
    Dir.glob(filename1, File::FNM_CASEFOLD).each do |filename1|
      ext = File.extname(filename1)
      filename2 = File.dirname(filename1) + "/" + File.basename(filename1).gsub(ext, "") + ext.downcase
      File.rename(filename1, filename2)
    end


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
