class UserMailer < ApplicationMailer
  #https://guides.rubyonrails.org/action_mailer_basics.html
  #https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/
  #https://nanceskitchen.com/2010/02/21/accept-incoming-emails-into-a-heroku-app-using-sendgrid/
  def receive(email)
    puts "email received"
    #   if email.has_attachments?
    #     email.attachments.each do |attachment|
    #       page.attachments.create({
    #         file: attachment,
    #         description: email.subject
    #       })
    #     end
    #   end
    # end
  end
