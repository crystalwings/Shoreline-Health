class SymptomsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @symptom = current_user.symptoms.new
    @symptoms = @user.symptoms
  end

  def show
    @symptom = Symptom.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @symptom }
    end
  end

  def update
    @symptom = Symptom.find(params[:id])
    @symptom.update(symptom_params)

    respond_to do |format|
      format.html { redirect_to user_dashboard_path(User.find(@sympyom.user_id)), notice: 'Successfully updated!' }
      format.json { head :no_content }
    end
  end

  def edit
    @symptom = Symptom.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @symptom }
    end
  end

  def new
    @user = User.find(params[:user_id])
    @symptom = @user.symptoms.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @symptom }
    end
  end

  def destroy
    @symptom = Symptom.find(params[:id])
    @user = @symptom.user
    @symptom.destroy
    redirect_to user_dashboard_path(@symptom.user), flash: { info: "Successfully destroyed symptom."}
  end

  def create
    @user = User.find(symptom_params[:user_id])
    @symptom = @user.symptoms.new( symptom_params)

    respond_to do |format|
      if @symptom.save
        if params[:images]
          #===== The magic is here ;)
          params[:images].each { |image|
            @symptom.photos.create(image: image)
            }
        end
        if @user.id != current_user.id
          @user.send_notification("A symptom/event has been added to your record by " + current_user.full_name, 'heartbeat')
        end
        format.html { redirect_to user_dashboard_path(@symptom.user), notice: 'symptom was successfully created.' }
        format.json { render json: @symptom, status: :created, location: @symptom }
      else
        format.html { render action: "new" }
        format.json { render json: @symptom.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def symptom_params
    params.require(:symptom).permit(:user_id, :description, :date_occured)
  end
end
