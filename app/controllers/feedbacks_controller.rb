require 'will_paginate/array'
class FeedbacksController < ApplicationController
  before_action :require_login
  before_action :require_admin, only: [:index, :show, :destroy, :update]
  before_action :get_user_detail
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
   
  helper_method :sort_column, :sort_direction

  def get_user_detail
    @user = current_user
  end
  # GET /feedbacks
  #this code is referenced from https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/
  def index    
    @feedbacks = Feedback.all
    respond_to do |format|
      format.html
      format.csv { send_data @feedbacks.to_csv, filename: "feedbacks.csv" }
    end
    
    @feedbacks = current_user.managed_feedbacks.paginate(:page => params[:page], :per_page=>15)

    # Reference website: http://burnignorance.com/ruby-development-tips/add-pagination-in-rails/
    if params[:priority] 
      sql_query = "SELECT * FROM feedbacks WHERE "
      params[:priority].each_with_index do |priority, index| 
        # p index
        sql_query += "priority = #{priority} "
        if index < params[:priority].size - 1
          sql_query += "or "
        end 
      
      end
      # Reference website: https://stackoverflow.com/questions/2535858/is-it-possible-to-combine-will-paginate-with-find-by-sql
      if (!(Feedback.find_by_sql(sql_query).empty?))
        @feedbacks = Feedback.paginate_by_sql(sql_query, :page => params[:page], :per_page=>15)
      else 
        @feedbacks = nil
        flash.now[:error] = 'There are no feedbacks with chosen priority.'
      end 
    end
  end

  # GET /feedbacks/1
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
    @team = Team.find_by(id: params[:team_id])
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks
  def create

      team_submissions = @user.one_submission_teams
      
      @feedback = Feedback.new(feedback_params)
      @team = Team.find_by(id: params[:team_id])
    
      @feedback.timestamp = @feedback.format_time(now)
      @feedback.user = @user
      @feedback.team = @team

      # calculates the individual rating for each feedback submitted
      @feedback.rating = ((params[:feedback][:collaboration_score].to_f  + params[:feedback][:communication_score].to_f  + 
      params[:feedback][:time_management_score].to_f  + params[:feedback][:problem_solving_score].to_f  + 
      params[:feedback][:knowledge_of_roles_score].to_f)/5.0).round(1)

      if team_submissions.include?(@feedback.team)
          redirect_to root_url, notice: 'You have already submitted feedback for this team this week.'
      elsif @feedback.save
        redirect_to root_url, notice: "Feedback was successfully created. Time created: #{@feedback.timestamp}"
      else
        render :new
      
    end

    
  end


  # PATCH/PUT /feedbacks/1
  # def update
  #   if @feedback.update(feedback_params)
  #     redirect_to @feedback, notice: 'Feedback was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # DELETE /feedbacks/:id
  # def destroy
  #   @feedback = Feedback.find(params[:id])
  #   @feedback.destroy
  #   redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.'
  # end

  private     
    def filtering_params(params)
        params.slice(:priority)
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def feedback_params
      params.require(:feedback).permit(:rating, :collaboration_score, :communication_score,
      :time_management_score, :problem_solving_score, :knowledge_of_roles_score, :comments, :priority, :timestamp)
    end

    def sort_column
      params[:sort] || "timestamp"
    end
  
    def sort_direction
      params[:direction] || "asc"
    end
end
