class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy, :add_contact, :update_contact, :add_brochure, :update_brochure, :get_qr_code, :usage, :usage_image]

  # GET /sheets
  # GET /sheets.json
  def index
    @sheets = Sheet.all
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
  end

  # GET /sheets/new
  def new
    @sheet = Sheet.new
  end

  def new
    @sheet = Sheet.new
  end

  # GET /sheets/1/edit
  def edit
  end

  def location
    render "test" #{}"location" #, :layout => "location"

  end


  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = Sheet.new(sheet_params)

    o = [('0'..'9')].map(&:to_a).flatten
    loop do
      number = (1..10).map { o[SecureRandom.random_number(o.length)] }.join
      if Sheet.where(:number => number).count == 0
        @sheet.number = number
        break
      end
    end

    respond_to do |format|
      if @sheet.save
        format.html { redirect_to @sheet, notice: 'Sheet was successfully created.' }
        format.json { render :show, status: :created, location: @sheet }
      else
        format.html { render :new }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sheets/1
  # PATCH/PUT /sheets/1.json
  def update
    @sheet.update(sheet_params)
    redirect_to sheets_path
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet.destroy
    respond_to do |format|
      format.html { redirect_to sheets_url, notice: 'Sheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_contact
    @sheet.check_orders_number_are_null
    Contact.all.order(:last_name, :first_name).each do |contact|
      s = params['check' + contact.id.to_s]
      if !s.blank?
        max_order = @sheet.max_order
        @sheet.contacts << contact
        @sheet.save
        contact_sheet = Conshejointable.where(:sheet_id => @sheet.id, :contact_id => contact.id).first
        contact_sheet.order_number = max_order
        contact_sheet.save
      end
    end
    redirect_to edit_sheet_path(@sheet)
  end

  def add_brochure
    @sheet.check_orders_number_are_null
    Brochure.all.order(:name).each do |brochure|
      s = params['check' + brochure.id.to_s]
      if !s.blank?
        max_order = @sheet.max_order
        @sheet.brochures << brochure
        @sheet.save
        b = Broshejointable.where(:sheet_id => @sheet.id, :brochure_id => brochure.id).first
        b.order_number = max_order
        b.save
      end
    end
    redirect_to edit_sheet_path(@sheet)
  end

  def update_contact
    if params[:commit] == "Update"
      @sheet.contacts.each do |contact|
        if !params["select"+ contact.id.to_s].blank?
          a = Conshejointable.where(:sheet_id => @sheet.id, :contact_id => contact.id).first
          puts "sheet: " + @sheet.id.to_s + "; contact: " + contact.id.to_s + "; description: " + params["select"+ contact.id.to_s]
          puts "id: " + a.id.to_s
          a.description_id = params["select"+ contact.id.to_s].to_i
          a.save
        end
      end

    elsif params[:commit] == "Remove contacts"

      @sheet.contacts.each do |contact|
        s = params['check' + contact.id.to_s]
        if !s.blank?
          @sheet.contacts.delete(contact)
          @sheet.save
        end
      end

      n = 0
      Conshejointable.where(:sheet_id => @sheet.id ).order(:order_number).each do |contact|
        contact.order_number = n
        contact.save
        n += 1
      end
    end

    redirect_to edit_sheet_path(@sheet)
  end


  def update_brochure
    if params[:commit] == "Remove brochures"

      @sheet.brochures.each do |brochure|
        s = params['check' + brochure.id.to_s]
        if !s.blank?
          @sheet.brochures.delete(brochure)
          @sheet.save
        end
      end

      n = 0
      Broshejointable.where(:sheet_id => @sheet.id ).order(:order_number).each do |brochure|
        brochure.order_number = n
        brochure.save
        n += 1
      end
    end

    redirect_to edit_sheet_path(@sheet)
  end



  def order_up
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = Conshejointable.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    contact_sheet2 = Conshejointable.where(:sheet_id => sheet_id, :order_number  => contact_sheet1.order_number - 1).first
    contact_sheet1.order_number -= 1
    contact_sheet2.order_number += 1
    contact_sheet1.save
    contact_sheet2.save

    redirect_to edit_sheet_path(sheet_id)
  end

  def to_top
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = Conshejointable.where(:sheet_id => sheet_id, :contact_id => contact_id).first

    Conshejointable.where(:sheet_id => sheet_id).where("order_number < ?",contact_sheet1.order_number).each do |contact|
      contact.order_number +=1
      contact.save
    end
    contact_sheet1.order_number = 0
    contact_sheet1.save

    redirect_to edit_sheet_path(sheet_id)
  end

  def to_bottom
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = Conshejointable.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    max_order = Conshejointable.where(:sheet_id => sheet_id).maximum(:order_number)

    Conshejointable.where(:sheet_id => sheet_id).where("order_number > ?",contact_sheet1.order_number).each do |contact|
      contact.order_number -=1
      contact.save
    end
    contact_sheet1.order_number = max_order

    contact_sheet1.save

    redirect_to edit_sheet_path(sheet_id)
  end


  def order_down
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = Conshejointable.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    contact_sheet2 = Conshejointable.where(:sheet_id => sheet_id, :order_number  => contact_sheet1.order_number + 1).first
    contact_sheet1.order_number += 1
    contact_sheet2.order_number -= 1
    contact_sheet1.save
    contact_sheet2.save

    redirect_to edit_sheet_path(sheet_id)
  end

  def contact_sheet
    contact_sheet1(true)
  end

  def contact_sheet_no_log
    contact_sheet1(false)
  end

  def contact_sheet1(log_flag)
    sheet_number = params[:id]
    if Sheet.where(:number => sheet_number).count > 0
      @sheet = Sheet.where(:number => sheet_number).first
      Log.create(:sheet_id => @sheet.id, :ip_address => request.remote_ip) if log_flag
      if mobile?
        render "sheet_mobile" , :layout => false
      else
        render "sheet" , :layout => false
      end
    else
      render 'sheet_number_error'
    end

  end

  def get_qr_code
    require 'rqrcode'

    qrcode = RQRCode::QRCode.new(contact_sheet_url(:id => @sheet.number))

    # NOTE: showing with default options specified explicitly
    # svg = qrcode.as_svg(
    #   offset: 0,
    #   color: '000',
    #   shape_rendering: 'crispEdges',
    #   module_size: 6,
    #   standalone: true
    # ).html_safe
    #
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )

    send_data png, :filename => "qr_code.png", :type => "image/jpg"
  end

  def usage

  end

  def usage_image
    # filename = "C:\\Users\\Dan\\Pictures\\airbnb picture.jpg"
    # image = MiniMagick::Image.open(filename)

    image = MiniMagick::Image.new(100,100)
    #image.format = "png"
    send_data image.to_blob, :filename => "picture"    # , :type => "application/pdf"

  end

  private
  def set_sheet
    @sheet = Sheet.find(params[:id])
  end
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def sheet_params
      params.require(:sheet).permit(:client_name, :password)
    end
end
