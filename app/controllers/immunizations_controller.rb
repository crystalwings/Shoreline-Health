class ImmunizationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @immunization = current_user.immunizations.new
    @immunizations = @user.immunizations
  end

  def show
    @immunization = Immunization.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @immunization }
    end
  end
  
  def update
    @immunization = Immunization.find(params[:id])
    @immunization.update(immunization_params)

    respond_to do |format|
      format.html { redirect_to user_immunizations_path(current_user), notice: 'Successfully updated!' }
      format.json { head :no_content }
    end
  end

  def edit
    @immunization = Immunization.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @immunization }
    end
  end

  def new
    @immunization = current_user.immunizations.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @immunization }
    end
  end

  def destroy
    @immunization = Immunization.find(params[:id])
    @user = @immunization.user
    @immunization.destroy
    redirect_to user_immunizations_path(@immunization.user), flash: { info: "Successfully destroyed immunization."}
  end

  def create
    @immunization = current_user.immunizations.new( immunization_params)

    respond_to do |format|
      if @immunization.save
        if @user != current_user.id 
          @user.send_notification(current_user.full_name + " has added an immunization record to your profile.", 'code-fork') 
        format.html { redirect_to user_immunizations_path(@immunization.user), notice: 'Immunization was successfully created.' }
        format.json { render json: @immunization, status: :created, location: @immunization }
      else
        format.html { render action: "new" }
        format.json { render json: @immunization.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def immunization_params
    params.require(:immunization).permit(:rec_age, :rec_dose, :date_taken, :user_id, :name, :description, :b_validated)
  end
end
