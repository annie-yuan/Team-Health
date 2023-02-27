
# This code is copied and modified from Hartl's 
# Ruby on Rails Tutorial, 6th edition.
# 
class SessionsController < ApplicationController

  def new
    if logged_in?
      redirect_to root_url 
    end
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      log_in user
      redirect_to root_url, notice: "Logged in."
    else
      flash.now[:error] = 'Cannot log you in. Invalid email or password.'
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url, notice: 'Logged out.'
  end
end
