class StaticPagesController < ApplicationController

  before_action :current_week, :get_teams
  helper_method :rating_reminders
  helper_method :days_till_end_week


  def home
    unless logged_in?
      redirect_to login_path
    else
      @user = current_user
      if @user.is_admin
        @courses = current_user.managed_courses
      end
      @rating_reminders = @user.rating_reminders
      @days_till_end_week = days_till_end(@now, @cweek, @cwyear)
      render :home
    end
  end

  def help
    unless logged_in?
      redirect_to login_path
    else
       if current_user.is_admin
         render :help
       else
         redirect_to root_url
       end
    end
  end

  def get_teams
    teams = Team.all
    @unsubmitted = {current_week: {}, previous_week: {}}
    @priority = {current_week: {}, previous_week: {}}
    teams.each do |team|
      @priority[:current_week][team] = team.find_priority_weighted(@week_range[:start_date], @week_range[:end_date])
      @priority[:previous_week][team] = team.find_priority_weighted(@week_range[:start_date], @week_range[:end_date])
      @unsubmitted[:current_week][team.id] = team.users_not_submitted(team.current_feedback).map{|user| user.name}
      @unsubmitted[:previous_week][team.id] = team.users_not_submitted(team.current_feedback(now - 7.days)).map{|user| user.name}
    end
    high_priority_teams = Array.new
    medium_priority_teams = Array.new
    low_priority_teams = Array.new
    no_feedback_teams = Array.new
    @priority[:current_week].each do |team, priority|
      if priority == "High"
        high_priority_teams.append(team)
      elsif priority == "Medium"
        medium_priority_teams.append(team)
      elsif priority == "Low"
        low_priority_teams.append(team)
      else
        no_feedback_teams.append(team)
      end
    end
    @teams = high_priority_teams.concat(medium_priority_teams, low_priority_teams, no_feedback_teams)
  end

  def show_reset_password
  end

  def reset_password
    unless logged_in?
      redirect_to login_path
    else
      @user = current_user
      if @user.authenticate(params[:existing_password])
        if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          flash[:notice] = 'Password successfully updated!'
          redirect_to root_url
        else
          flash[:error] = 'Password and password confirmation do not meet specifications'
          redirect_to reset_password_path
        end
      else
        flash[:error] = 'Incorrect existing password'
        redirect_to reset_password_path
      end
    end
  end

  def current_week
    @now = now
    @cweek = @now.cweek
    @cwyear = @now.cwyear
    @week_range = week_range(@cwyear, @cweek)
  end


end
