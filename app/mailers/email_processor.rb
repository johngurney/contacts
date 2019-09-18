class EmailProcessor
  #https://github.com/thoughtbot/griddler
  def initialize(email)
    @email = email
  end

  def process
    # all of your application-specific code here - creating models,
    # processing reports, etc

    text = @email.body

    logged_in = false
    add_flag = false
    sheet = nil

    text.each_line do |line|
      line.gsub!("\r\n", '').strip!
      if line == "clear" && sheet
        sheet.contacts
      values=line.split ":"
      logged_in = true if values[0].downcase == "password" && values.count > 1 && values[1] == Rails.configuration.system_password

      if values[0].downcase == "sheet" && values.count > 1
        temp_sheets = Sheet.where(:if => values[1]).or.Sheet.where(:name => values[1])
        temp_sheet = temp_sheets.first if  => temp_sheets.count == 1
        sheet = temp_sheet if logged_in || (values.count > 2 && temp_sheet.password == values[2])
      end

      if values[0].downcase == "clear" && !sheet.blank?
      end

      if values[0].downcase == "add" && !sheet.blank?
      end

    end

    if !sheet.blank?
      sheet.name += "+"
      sheet.save
    end

    #   values=line.split "\t"
    #
    # puts "Emails arrived"
    # puts "Email: " + @email.to_s
    # puts "From email: " + @email.from[:email]
    # puts "From name: " + @email.from[:name]
    # puts "Header: " + @email.headers.to_s
    # puts "Header: " + @email.headers.count.to_s
    # puts "Header: " + @email.headers["Date"]

    # here's an example of model creation
    # user = User.find_by_email(@email.from[:email])
    # user.posts.create!(
    #   subject: @email.subject,
    #   body: @email.body
    # )
  end
end
