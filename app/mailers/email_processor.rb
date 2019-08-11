class EmailProcessor
  #https://github.com/thoughtbot/griddler
  def initialize(email)
    @email = email
  end

  def process
    # all of your application-specific code here - creating models,
    # processing reports, etc

    puts "Emails arrived"
    puts "From email: " + @email.from[:email]
    puts "From name: " + @email.from[:name]
    puts "Header: " + @email.headers[0][:Date]

    # here's an example of model creation
    # user = User.find_by_email(@email.from[:email])
    # user.posts.create!(
    #   subject: @email.subject,
    #   body: @email.body
    # )
  end
end
