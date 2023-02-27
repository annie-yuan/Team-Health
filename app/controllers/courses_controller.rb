class CoursesController < ApplicationController

  before_action :current_week, :verify_logged_in
  helper_method :rating_reminders
  helper_method :days_till_end_week


  def show
    @course = Course.find(params[:id])
    @rating_reminders = @user.rating_reminders
    @days_till_end_week = days_till_end(@now, @cweek, @cwyear)
    @unsubmitted = {current_week: {}, previous_week: {}}
    @priority = {current_week: {}, previous_week: {}}

    teams = @course.teams
    
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

    if params[:current_priority] 
      priorities = params[:current_priority]
      puts priorities
      @current_teams = @teams.filter do |team|
        priorities.include? team.find_priority_weighted(@week_range[:start_date], @week_range[:end_date])
      end
    else
      @current_teams = @teams
    end

    if params[:previous_priority] 
      priorities = params[:previous_priority]
      puts priorities
      @previous_teams = @teams.filter do |team|
        priorities.include? team.find_priority_weighted((@week_range[:start_date] - 7.days), (@week_range[:end_date] - 7.days))
      end
    else
      @previous_teams = @teams
    end
    render :show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.admin = @user

    if @course.save
      flash[:notice] = "Successfully created #{@course.course_name}."
      redirect_to root_url
    else
      flash[:notice] = "Error creating course. Please try again!"
      render :new
    end
  end


  def verify_logged_in
    unless logged_in?
      redirect_to login_path
    else
      @user = current_user
      if not @user.is_admin
        raise StandardError.new "Only Admin can see teams in a course."
      end
    end
  end


  def current_week
    @now = now
    @cweek = @now.cweek
    @cwyear = @now.cwyear
    @week_range = week_range(@cwyear, @cweek)
  end

  private
    def course_params
      params.require(:course).permit(:course_name, :course_code)
    end
end
