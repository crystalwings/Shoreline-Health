class DoctorVisitsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @doctor_visits = @user.doctor_visits
  end

  def show
    @doctor_visit = DoctorVisit.find(params[:id])
    @user = @doctor_visit.user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @doctor_visit }
    end
  end

  def update
    @doctor_visit = DoctorVisit.find(params[:id])
    @doctor_visit.update(doctor_visit_params)

    respond_to do |format|
      format.html { redirect_to user_summary_path(current_user), notice: 'Successfully updated!' }
      format.json { head :no_content }
    end
  end

  def new
    @user = User.find(params[:user_id])
    @doctor_visit = @user.doctor_visits.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @doctor_visit }
    end
  end

  def edit
    @doctor_visit = DoctorVisit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @doctor_visit }
    end
  end

  def destroy
    @doctor_visit = DoctorVisit.find(params[:id])
    @user = @doctor_visit.user
    @doctor_visit.destroy
    redirect_to user_dashboard_path(@doctor_visit.user), :notice => "Successfully destroyed doctor_visit."
  end

  def create
    @doctor_visit = current_user.doctor_visits.new( doctor_visit_params)

    respond_to do |format|
      if @doctor_visit.save
        if @user != current_user.id 
          @user.send_notification(current_user.full_name + " has added a doctor visit to your profile", 'user-md') 
        if params[:photos]
          #===== The magic is here ;)
          params[:photos].each { |photo|
            @doctor_visit.photos.create(image: photo)
            }
        end
        format.html { redirect_to user_dashboard_path(@doctor_visit.user), notice: 'doctor_visit was successfully created.' }
        format.json { render json: @doctor_visit, status: :created, location: @doctor_visit }
      else
        format.html { render action: "new" }
        format.json { render json: @doctor_visit.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def doctor_visit_params
    params.require(:doctor_visit).permit(:user_id, :notes, :doctor, :album_id, :reason, :location)
  end
end
