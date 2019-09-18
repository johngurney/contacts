class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy, :add_contact, :update_contact, :add_brochure, :update_brochure]

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

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = Sheet.new(sheet_params)

    o = [('0'..'9')].map(&:to_a).flatten
    loop do
      number = (1..6).map { o[SecureRandom.random_number(o.length)] }.join
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
    respond_to do |format|
      if @sheet.update(sheet_params)
        format.html { redirect_to @sheet, notice: 'Sheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @sheet }
      else
        format.html { render :edit }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
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

  def sheet
    sheet_number = params[:id]
    if Sheet.where(:number => sheet_number).count > 0
      @sheet = Sheet.where(:number => sheet_number).first
      if mobile?
        render "sheet_mobile" , :layout => false
      else
        render "sheet" , :layout => false
      end
    else
      render 'sheet_number_error'
    end

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
