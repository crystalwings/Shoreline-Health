class HandshakesController < ApplicationController
  def create
    @user = User.find(params[:handshake][:followed_id])
    current_user.handshake!(@user)
    @user.send_notification("You have been added to the network of " + current_user.full_name, 'user-plus')
    respond_to do |f|
      f.html { redirect_to user_network_path(current_user) }
      f.js
    end
  end

  def edit
    @user = current_user
    @handshake = Handshake.find(params[:id])
    #@conditions = @page.conditions

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @handshake }
    end
  end 
  
  def update
    @handshake = Handshake.find(params[:id])
    @handshake.update(handshake_params)

    respond_to do |format|
      format.html { redirect_to user_network_path(current_user), notice: 'Relationship type was updated.' }
      format.json { head :no_content }
    end
  end

  def show
    @handshake = Handshake.find(params[:id])
    @user = current_user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @handshake }
    end
  end

  def destroy
    @handshake = Handshake.find(params[:id])
    @user = @handshake.follower
    @handshake.destroy
    redirect_to user_network_path(@user), :notice => "Removed friendship."
  end

  private

  def handshake_params
    params.require(:handshake).permit(:user_id, :followed_id, :relationship_name, :relationship_type)
  end
end
