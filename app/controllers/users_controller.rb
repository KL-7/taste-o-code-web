class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :check_edit_permission, :only => [:edit, :update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id].to_i)
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user)
    else
      render :action => 'edit'
    end
  end

  protected

  def check_edit_permission
    if params[:id] == current_user.id.to_s
      @user = current_user
    else
      redirect_to :action => :show, :id => params[:id]
    end
  end

end
