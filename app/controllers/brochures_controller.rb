class BrochuresController < ApplicationController
  before_action :set_brochure, only: [:show, :edit, :update, :destroy, :upload_picture, :get_picture, :upload_pdf, :download_content]

  # GET /brochures
  # GET /brochures.json
  def index
    @brochures = Brochure.all
  end

  # GET /brochures/1
  # GET /brochures/1.json
  def show
  end

  # GET /brochures/new
  def new
    @brochure = Brochure.new
  end

  # GET /brochures/1/edit
  def edit
  end

  # POST /brochures
  # POST /brochures.json
  def create
    @brochure = Brochure.new(brochure_params)

    respond_to do |format|
      if @brochure.save
        format.html { redirect_to @brochure, notice: 'Brochure was successfully created.' }
        format.json { render :show, status: :created, location: @brochure }
      else
        format.html { render :new }
        format.json { render json: @brochure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brochures/1
  # PATCH/PUT /brochures/1.json
  def update
    @brochure.update(brochure_params)
    redirect_to edit_brochure_path(@brochure)
  end

  # DELETE /brochures/1
  # DELETE /brochures/1.json
  def destroy
    @brochure.destroy
    respond_to do |format|
      format.html { redirect_to brochures_url, notice: 'Brochure was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_picture

    if !@brochure.image.blank?

      # filename = "D:\\projects\\contacts\\public\\pictures\\picture" + @contact.id.to_s + ".jpg"
      # image = MiniMagick::Image.open(filename)

      image = MiniMagick::Image.read(@brochure.image )


      if @brochure.rotation.blank?
        @brochure.rotation = 0
        @brochure.save(validate: false)
      end

      image.rotate (@brochure.rotation * 90).to_s

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
      send_data image.to_blob, :filename => "picture.jpg", :type => "image/jpg"
    end
  end

  def upload_picture

    if @brochure.rotation.blank?
      @brochure.rotation = 0
      @brochure.save(validate: false)
    end

    if params[:commit] == "Rotate left"
      @brochure.rotation -= 1
      @brochure.rotation = 3 if @brochure.rotation < 0
      @brochure.save

    elsif  params[:commit] == "Rotate right"
      @brochure.rotation += 1
      @brochure.rotation = 0 if @brochure.rotation > 3
      @brochure.save

    elsif  params[:commit] == "Upload from URL"
      require 'open-uri'
      url = params[:picture_url]
      uri = URI.parse(url)
      image_data = uri.read
      @brochure.image = image_data
      @brochure.save

    elsif  params[:commit] == "Delete"
      @brochure.image = nil
      @brochure.save
      # filename = Rails.root.join("public", @contact.picture_filename).to_s
      # File.delete(filename) if File.exist?(filename)

    elsif  params[:commit] == "Upload"
      # dirname = Rails.root.join('public', 'pictures')
      # Dir.mkdir(dirname) unless Dir.exist?(dirname)
      #

      uploaded_io = params[:picture_file]

      if File.extname(uploaded_io.original_filename).downcase == ".jpg"
        image_data = uploaded_io.read
        @brochure.image = image_data
        @brochure.save
      end

      # if File.extname(uploaded_io.original_filename).downcase == ".jpg"
      #   filename = Rails.root.join("public", @contact.picture_filename).to_s
      #   File.delete(filename) if File.exist?(filename)
      #   File.open(filename, 'wb') do |file|
      #     file.write(image_data)
      #   end
      # end

    end

    redirect_to edit_brochure_path(@brochure)

  end

  def upload_pdf

    if  params[:commit] == "Delete"
      @brochure.content = nil
      @brochure.save
      # filename = Rails.root.join("public", @contact.picture_filename).to_s
      # File.delete(filename) if File.exist?(filename)

    elsif  params[:commit] == "Upload"
      # dirname = Rails.root.join('public', 'pictures')
      # Dir.mkdir(dirname) unless Dir.exist?(dirname)
      #

      uploaded_io = params[:pdf_file]

      if File.extname(uploaded_io.original_filename).downcase == ".pdf"
        image_data = uploaded_io.read
        @brochure.content = image_data
        @brochure.save
      end

      # if File.extname(uploaded_io.original_filename).downcase == ".jpg"
      #   filename = Rails.root.join("public", @contact.picture_filename).to_s
      #   File.delete(filename) if File.exist?(filename)
      #   File.open(filename, 'wb') do |file|
      #     file.write(image_data)
      #   end
      # end

    end

    redirect_to edit_brochure_path(@brochure)

  end

  def download_content
    if @brochure.has_content?
        send_data(
        @brochure.content,
        filename: @brochure.name + ".pdf",
        type: "application/pdf" )
    end
  end







  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brochure
      @brochure = Brochure.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brochure_params
      params.require(:brochure).permit(:name)
    end
end
