class TeamsController < ApplicationController
  before_action :require_login
  before_action :require_admin, except: [:show, :help]
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  helper_method :sort_column, :sort_direction
  # GET /teams
  #this code is referenced from "https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/"
  def index  
      @teams = Team.all
      respond_to do |format|
        format.html
        format.csv { send_data @teams.to_csv, filename: "teams.csv" }
      end
      # Reference website: http://burnignorance.com/ruby-development-tips/add-pagination-in-rails/    
      @teams = current_user.managed_teams.order(sort_column + ' ' + sort_direction).paginate(:page => params[:page], :per_page=>15)
    end

  # GET /teams/1
  def show
    if !is_admin?
      if !@current_user.teams.include? @team
        flash[:notice] = "You do not belong to this team!"
        redirect_to root_url
      end
    end

    @periods = @team.feedback_by_period
    if !@periods.nil?
      @periods.each do |period|
        period << week_range(period[0][:year], period[0][:week])
        period << Feedback::average_rating(period[1])
        period << @team.users_not_submitted(period[1]).map{|user| user.name}

        wk_range = week_range(period[0][:year], period[0][:week])
        period << @team.find_priority_weighted(wk_range[:start_date], wk_range[:end_date])
      end
    end
  end

  # GET /teams/help
  def help
    render :help
  end

  # GET /teams/new
  def new
    @team = Team.new
    @edit = false
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
    @edit = true
  end

  # POST /teams
  def create
    params = team_params
    @team = Team.new(team_name: params[:team_name], team_code: params[:team_code])
    course = Course.find_by(course_code: params[:course_code])
    if not course
      flash[:notice] = "Course code doesn't exist"
      redirect_back(fallback_location: root_path)
      return 
    end
    @team.course = course
    
    team_exists = Team.find_by_sql(["SELECT * FROM teams as t, courses as c WHERE t.course_id = c.id AND c.course_code=? and t.team_name='#{params[:team_name]}'", params[:course_code]])
    if team_exists.present?
      flash[:error] = "Team name is already in use"
      redirect_back(fallback_location: root_path)
      return 
    elsif @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /teams/1
  def update
    params = team_params
    if @team.update(team_name: params[:team_name], team_code: params[:team_code])
      redirect_to teams_url, notice: 'Team was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /teams/1
  def destroy
    @team.users = []
    @team.feedbacks.each do |feedback|
      feedback.destroy
    end
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully destroyed.'
  end


  def confirm_delete
    @team = Team.find(params[:id])
  end

  def remove_user_from_team
    # Taken from https://stackoverflow.com/questions/12023854/rails-remove-child-association-from-parent
    @user = User.find(params[:user_id])
    @team = @user.teams.find(params[:team_id])
    @user.teams.delete(@team)
    redirect_to  root_url, notice: 'User removed successfully.'
  end

  def confirm_delete_user_from_team
    @user = User.find(params[:user_id])
    @team = @user.teams.find(params[:team_id])
  end

   def add_members
    @team = Team.find(params[:id])
    member = User.where(email: params[:user_email]).first
    if member.nil?
      flash[:notice] = "There is no user with #{params[:user_email]}."
    elsif @team.users.exists?(member.id)
      # status 0
      if JoinTeamStatus.find_by(team: @team, user: member).status == 0
        flash[:notice] = "An invite to #{member.name} has already been sent."
      # status 1
      elsif JoinTeamStatus.find_by(team: @team, user: member).status == 1
        flash[:notice] = "#{member.name} is already added to the team."
      end
    else
      @team.course.teams.each do |team|
        if team.users.exists?(member.id)
          flash[:notice] = "#{member.name} is already in #{team.team_name} for #{team.course.course_name}."
          return redirect_to teams_url
        end
      end
      @team.join_team_statuses.create(user: member, status: 0)
      @team.course.users << member
      flash[:notice] = "Successfully invited #{member.name} to #{@team.team_name}."
    end

    redirect_to teams_url

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def team_params
      params.require(:team).permit(:team_name, :course_code, :team_code)
    end

  private
  def sort_column
    params[:sort] || "team_name"
  end

  def sort_direction
    params[:direction] || "asc"
  end
end
