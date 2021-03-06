class UsergroupsController < ApplicationController
  before_action :set_usergroup, only: [:show, :edit, :update, :destroy]

  # GET /usergroups
  # GET /usergroups.json
  def index
    @usergroups = Usergroup.all
  end

  # GET /usergroups/1
  # GET /usergroups/1.json
  def show
  end

  # GET /usergroups/new
  def new
    @usergroup = Usergroup.new
  end

  # GET /usergroups/1/edit
  def edit
  end

  # POST /usergroups
  # POST /usergroups.json
  def create
    @usergroup = Usergroup.new(usergroup_params)

    respond_to do |format|
      if @usergroup.save
        format.html { redirect_to @usergroup, notice: 'Usergroup was successfully created.' }
        format.json { render :show, status: :created, location: @usergroup }
      else
        format.html { render :new }
        format.json { render json: @usergroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usergroups/1
  # PATCH/PUT /usergroups/1.json


  def update
    if params[:commit] == "Remove users"
      @usergroup.users.each do |user|
        @usergroup.users.delete(user) if params[:usergroup]["user" + user.id.to_s] == "1"
      end
    elsif params[:commit] == "Add users"
      User.all.each do |user|
        @usergroup.users << user if params[:usergroup]["user" + user.id.to_s] == "1"
      end
    else
      @usergroup.update(usergroup_params)
    end
    redirect_to users_path
  end

  # DELETE /usergroups/1
  # DELETE /usergroups/1.json
  def destroy
    @usergroup.destroy
    respond_to do |format|
      format.html { redirect_to usergroups_url, notice: 'Usergroup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usergroup
      @usergroup = Usergroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usergroup_params
      params.require(:usergroup).permit(:name, :url, :bespoke, :north, :south, :west, :east, :draggable)
    end
end
