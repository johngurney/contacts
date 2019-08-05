class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy, :add_contact, :remove_contact, :test]

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
        contact_sheet = ContactSheet.where(:sheet_id => @sheet.id, :contact_id => contact.id).first
        contact_sheet.order_number = max_order
        contact_sheet.save
      end
    end
    redirect_to sheet_path(@sheet)
  end


  def remove_contact
    Contact.all.each do |contact|
      s = params['check' + contact.id.to_s]
      if !s.blank?
        @sheet.contacts.delete(contact)
        @sheet.save
      end
    end

    n = 0
    ContactSheet.where(:sheet_id => @sheet.id ).order(:order_number).each do |contact|
      contact.order_number = n
      contact.save
      n += 1
    end

    redirect_to sheet_path(@sheet)
  end

  def order_up
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = ContactSheet.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    contact_sheet2 = ContactSheet.where(:sheet_id => sheet_id, :order_number  => contact_sheet1.order_number - 1).first
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
    contact_sheet1 = ContactSheet.where(:sheet_id => sheet_id, :contact_id => contact_id).first

    ContactSheet.where(:sheet_id => sheet_id).where("order_number < ?",contact_sheet1.order_number).each do |contact|
      contact.order_number +=1
      contact.save
    end
    contact_sheet1.order_number = 0
    contact_sheet1.save

    redirect_to edit_sheet_path(sheet_id)
  end

  def test
    puts "TEST"
    puts "Max:" + @sheet.max_order.to_s

    redirect_to edit_sheet_path(@sheet)
  end

  def to_bottom
    sheet_id = params[:sheet_id]
    Sheet.find(sheet_id).check_orders_number_are_null
    contact_id = params[:contact_id]
    contact_sheet1 = ContactSheet.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    max_order = ContactSheet.where(:sheet_id => sheet_id).maximum(:order_number)

    ContactSheet.where(:sheet_id => sheet_id).where("order_number > ?",contact_sheet1.order_number).each do |contact|
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
    contact_sheet1 = ContactSheet.where(:sheet_id => sheet_id, :contact_id => contact_id).first
    contact_sheet2 = ContactSheet.where(:sheet_id => sheet_id, :order_number  => contact_sheet1.order_number + 1).first
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
      params.require(:sheet).permit(:client_name)
    end
end
