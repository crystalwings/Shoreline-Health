class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :add_breadcrumbs, only: [:show]

  def update

  end

  def mark_read 
    @user = User.find(params[:user_id])
    @user.notifications.each do |f|
      f.update_attribute(:b_read, true)
    end
    redirect_to user_notifications_path(@user)
  end

  def printable
    @user = User.find(params[:user_id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
  end

  def index
    @users = User.all.paginate(:page => params[:page], :per_page => 25).order('first_name ASC')
    @user = current_user
  end

  def apps
    @user = User.find(params[:user_id])
    @conditions = @user.conditions
    @unfinished_goals = @user.goals.get_unfinished

    if current_user.id == @user.id
      render action: :apps
    elsif current_user.following?(@user)
      render action: :apps 
    else
      render file: 'public/denied'
    end
  end

  def metrics
    @user = User.find(params[:user_id])
    @tracker = current_user.trackers.new
    if current_user.id == @user.id
      render action: :metrics
    else
      render file: 'public/denied'
    end
  end
  
  def dashboard
    require 'will_paginate/array'
    @user = User.find(params[:user_id])
    @medications = @user.medications.order('created_at ASC')
    @allergies = @user.allergies.order('created_at DESC')
    @doctor_visits = @user.doctor_visits.order('created_at DESC')
    @conditions = @user.conditions.order('created_at DESC')
    @immunizations = @user.immunizations.order('created_at DESC')
    @symptoms = @user.symptoms.order('created_at DESC')
    #@things = (@medications + @allergies + @doctor_visits).paginate(:page => params[:page], :per_page => 25)
    @things = (@medications + @doctor_visits).sort{|a,b| a.created_at <=> b.created_at }.reverse
    @things = (@things + @conditions)
    @things = (@things + @immunizations)
    @things = (@things + @symptoms)
    @things = (@things + @allergies).sort{|a,b| a.created_at <=> b.created_at }.reverse
    @things_month = @things.group_by { |t| t.created_at.beginning_of_month }
    if current_user.id == @user.id
      render action: :dashboard
    else
      render file: 'public/denied'
    end
  end
  
  def summary
    @user = User.find(params[:user_id])
    @autocomplete_pages = Page.all
    if current_user.id == @user.id
      render action: :summary
    else
      render file: 'public/denied'
    end
  end

  def network
    @user = User.find(params[:user_id])
    #@unfinished_goals = @user.goals.get_unfinished

    if current_user.id == @user.id
      render action: :network
    else
      render file: 'public/denied'
    end
  end
  
  def network_feed
    @user = User.find(params[:user_id])
    #@unfinished_goals = @user.goals.get_unfinished

    if current_user.id == @user.id
      render action: :network_feed
    else
      render file: 'public/denied'
    end
  end

  def network_permissions
    @user = User.find(params[:user_id])
    if current_user.id == @user.id
      render action: :network_permissions
    else
      render file: 'public/denied'
    end
  end

  def show
    @user = User.find(params[:id])
    @droplet = Droplet.new
    @unfinished_goals = @user.goals.get_unfinished
    @conditions = @user.conditions.order("created_at DESC")
    
    if current_user.id == @user.id
      redirect_to user_dashboard_path(@user)
    elsif current_user.following?(@user)
      render action: :show 
    else
      render file: 'public/denied', formats: [:html]
    end
  end

  def ecard
    @user = User.find(params[:user_id])

    if current_user.id == @user.id
      render action: :show
    else
      render file: 'public/denied'
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def add_breadcrumbs

    @user = User.find(params[:id])
    add_breadcrumb @user.first_name, user_path(@user)
    add_breadcrumb "Albums", albums_path

  end

  def user_params
    params.require(:user).permit(:b_use_btn_labels, :b_use_wallpaper, :wallpaper_url, :imageurl, :bio, :gender, :doner, :bloodtype, :address, :date_of_birth, :email, :profile_name, :first_name, :last_name, :avatar, conditions_attributes: [:page_id], goals_attributes: [:unfinished_goals, :user_id], allergies_attributes: [ :user_id, :name, :description ] )
  end

end
