class ContactsController < ApplicationController

  before_action :set_contact, only: [:show, :edit, :update, :destroy, :desc, :upload_picture, :get_picture]
  # skip_before_action :verify_authenticity_token, only: :desc

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit


  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if (Contact.where("lower(email_address) = ?", contact.email_address).count == 0) and @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :edit, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { render :edit, notice: 'Contact was successfully updated.' }
        format.json { render :edit, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    Conshejointable.where(:contact_id =>@contact.id).delete_all
    Description.where(:contact_id =>@contact.id).delete_all
    puts @contact.id.to_s + ": " + @contact.name
    @contact.delete
    respond_to do |format|
      format.html { redirect_to contacts_path, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_all_contacts

    Contact.delete_all
    Conshejointable.delete_all

    redirect_to contacts_path
  end


  def upload_contacts_file

    uploaded_io = params[:file]
    text = uploaded_io.read

    flag = false
    first_name_column = -1
    last_name_column = -1
    position_column = -1
    tel_number_column = -1
    mobile_number_column = -1
    email_address_column = -1

    text.each_line do |line|
      line.gsub!("\r\n", '')

      values=line.split "\t"
      if flag == false
        puts values.to_s
        first_name_column = find_in_array(values, "first_name")
        last_name_column = find_in_array(values, "last_name")
        position_column = find_in_array(values, "position")
        tel_number_column = find_in_array(values, "tel_number")
        mobile_number_column = find_in_array(values, "mobile_number")
        email_address_column = find_in_array(values, "email_address")
        flag=true
      else

        contact = Contact.new
        if first_name_column >= 0
          contact.first_name = values[first_name_column]
        end
        if last_name_column >= 0
          contact.last_name  = values[last_name_column]
        end
        if position_column >= 0
          contact.position   = values[position_column]
        end
        if tel_number_column >= 0
          contact.tel_number   = values[tel_number_column]
        end
        if mobile_number_column >= 0
          contact.mobile_number   = values[mobile_number_column]
        end
        #puts "**" + email_address_column.to_s
        if email_address_column >= 0
          contact.email_address   = values[email_address_column]
        end
        contact.save if Contact.where("lower(email_address) = ?", contact.email_address).count == 0

      end
    end

    redirect_to contacts_path
  end

  def find_in_array(arry , text)
    a = arry.index{|v| v.downcase == text.downcase}
    if a.blank?
      -1
    else
      a
    end
  end


  #http://localhost:3000/contacts/291/edit

  def desc
    if params[:commit] == "Add"
      description = Description.new(:name => params[:name], :text => params[:desc_text])
      @contact.descriptions << description
      description.save(validate: false)
      @contact.save
      set_selector_name_descriptiontext(@contact, description.id)

    elsif params[:commit] == "Rename"
      description = Description.find(params[:select].to_i)
      description.name = params[:name]
      description.save(validate: false)
      set_selector_name_descriptiontext(@contact, description.id)

    elsif params[:commit] == "Update text"
      description = Description.find(params[:select].to_i)
      description.text = params[:desc_text]
      description.save(validate: false)
      set_selector_name_descriptiontext(@contact, description.id)

    elsif params[:commit] == "Delete"
      description = Description.find(params[:select].to_i)
      descs_in_order = @contact.descs_in_order
      if descs_in_order.count > 1
        desc_order_number = descs_in_order.pluck(:id).index(description.id)
        desc_order_number -=1 if desc_order_number  > 0
      end
      description.delete
      if desc_order_number.blank?
        set_selector_name_descriptiontext(@contact,  0)
      else
        set_selector_name_descriptiontext(@contact,  descs_in_order[desc_order_number].id)
      end

    elsif params[:commit] == "Select"
      description = Description.find(params[:select].to_i)
      @description_text = description.text
      @name = description.name
      @selector = @contact.set_selector(description.id)
      puts "!!!!" + description.id.to_s + "; " + @description_text

    else
      return
    end

    respond_to do |format|
      format.js { render 'description'}
      puts "send js"
    end
  end

  def set_selector_name_descriptiontext(contact, description_id)
    @selector = contact.set_selector(description_id)
    @name = description_id > 0 ? Description.find(description_id).name : ""
    @description_text = description_id > 0 ? Description.find(description_id).text : ""
  end

  def get_picture

    if !@contact.image.blank?

      file_name = Rails.root.join('app', 'assets', 'images', 'cms.png')
      # image = MiniMagick::Image.open(filename)

      image = MiniMagick::Image.read(@contact.image )


      if @contact.rotation.blank?
        @contact.rotation = 0
        @contact.save(validate: false)
      end

      image.rotate (@contact.rotation * 90).to_s

      original_width = image.width
      original_height = image.height

      desired_width = 200
      maximum_height = 300

      if original_height / original_width * desired_width < maximum_height
        width = desired_width
        height = width * original_height / original_width
      else
        height = maximum_height
        width = height * original_width / original_height
      end

      image.resize width.to_s + "x" + height.to_s + ">"


      image = File.open(file_name, "rb")
      # send_data image.to_blob, :filename => "picture"  , :type => "image/png"
      send_data image.read, :filename => "picture.png", :type => "image/png"
    end
  end

  def upload_picture

    if @contact.rotation.blank?
      @contact.rotation = 0
      @contact.save(validate: false)
    end

    if params[:commit] == "Rotate left"
      @contact.rotation -= 1
      @contact.rotation = 3 if @contact.rotation < 0
      @contact.save

    elsif  params[:commit] == "Upload from URL"
      require 'open-uri'
      url = params[:picture_url]
      uri = URI.parse(url)
      image_data = uri.read
      @contact.image = image_data
      @contact.save

    elsif  params[:commit] == "Rotate right"
      @contact.rotation += 1
      @contact.rotation = 0 if @contact.rotation > 3
      @contact.save

    elsif  params[:commit] == "Delete"
      @contact.image = nil
      @contact.save
      # filename = Rails.root.join("public", @contact.picture_filename).to_s
      # File.delete(filename) if File.exist?(filename)

    elsif  params[:commit] == "Upload"
      # dirname = Rails.root.join('public', 'pictures')
      # Dir.mkdir(dirname) unless Dir.exist?(dirname)
      #

      uploaded_io = params[:picture_file]

      if File.extname(uploaded_io.original_filename).downcase == ".jpg"
        image_data = uploaded_io.read
        @contact.image = image_data
        @contact.save
      end

      # if File.extname(uploaded_io.original_filename).downcase == ".jpg"
      #   filename = Rails.root.join("public", @contact.picture_filename).to_s
      #   File.delete(filename) if File.exist?(filename)
      #   File.open(filename, 'wb') do |file|
      #     file.write(image_data)
      #   end
      # end

    end

    redirect_to edit_contact_path(@contact)

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :email_address, :position, :tel_number, :mobile_number, :url)
    end
end
