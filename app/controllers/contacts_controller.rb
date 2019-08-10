class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

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
        format.json { render :show, status: :created, location: @contact }
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
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def delete_all_contacts

    Contact.delete_all
    ContactSheet.delete_all

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
