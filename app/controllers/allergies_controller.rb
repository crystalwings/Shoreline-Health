class AllergiesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @allergies = @user.allergies
  end

  def show
    @allergy = Allergy.find(params[:id])
    @user = @allergy.user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @allergy }
    end
  end

  def update
    @allergy = Allergy.find(params[:id])
    @allergy.update(allergy_params)

    respond_to do |format|
      format.html { redirect_to user_summary_path(current_user), notice: 'Successfully updated!' }
      format.json { head :no_content }
    end
  end

  def new
    @user = User.find(params[:user_id])
    @allergy = @user.allergies.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @allergy }
    end
  end
  
  def edit
    @allergy = Allergy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @allergy }
    end
  end
  
  def destroy
    @allergy = Allergy.find(params[:id])
    @user = @allergy.user
    @allergy.destroy
    redirect_to user_summary_path(@allergy.user), :notice => "Successfully destroyed allergy."
  end

  def create
    @allergy = current_user.allergies.new( allergy_params)

    respond_to do |format|
      if @allergy.save
        if @user != current_user.id 
          @user.send_notification(current_user.full_name + " has added an allergy to your profile", 'bug') 
        format.html { redirect_to user_summary_path(@allergy.user), notice: 'Allergy was successfully created.' }
        format.json { render json: @allergy, status: :created, location: @allergy }
      else
        format.html { render action: "new" }
        format.json { render json: @allergy.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def allergy_params
    params.require(:allergy).permit(:user_id, :name, :description)
  end
end
