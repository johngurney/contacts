class SheetsController < ApplicationController
  before_action :set_sheet, only: [:show, :edit, :update, :destroy, :add_contact, :remove_contact]

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
    Contact.all.each do |contact|
      s = params['check' + contact.id.to_s]
      if !s.blank?
        @sheet.contacts << contact
      end
    end
    redirect_to sheet_path(@sheet)
  end

  def remove_contact
    Contact.all.each do |contact|
      s = params['check' + contact.id.to_s]
      if !s.blank?
        @sheet.contacts.delete(contact)
      end
    end
    redirect_to sheet_path(@sheet)
  end

  def sheet
    sheet_number = params[:id]
    if Sheet.where(:number => sheet_number).count > 0
      @sheet = Sheet.where(:number => sheet_number).first
      render "sheet" , :layout => false
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
