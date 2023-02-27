class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :require_admin, except: [:new, :create, :update, :edit, :accept_team_invite]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  helper_method :sort_column, :sort_direction

  # GET /users
  #this code is referenced from https://findnerd.com/list/view/Importing-and-Exporting-Records-in-CSV-format-in-Rails/21377/
  def index
    # Reference website: http://burnignorance.com/ruby-development-tips/add-pagination-in-rails/
    @users = User.all
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv, filename: "users.csv" }
    end
    @users = current_user.managed_students.order(sort_column + ' ' + sort_direction).paginate(:page => params[:page], :per_page=>15)
  end
  # GET /users/1
  def show
  end
  # GET /signup
  def new
    if logged_in? 
      redirect_to root_url 
    end 
    
    @user = User.new
  end
  # GET /users/1/edit
  def edit
  end
  
  # POST /users
  def create    
    final_user_params = user_params.except(:admin_code)
        
    @user = User.new(final_user_params)
    @user.valid?
    if not user_params[:admin_code].nil? and not user_params[:admin_code].size==0
      if user_params[:admin_code] == Option.first.admin_code
        @user.is_admin = true
        @user.valid?
      else
        @user.errors.add :base, :invalid, message: "Invalid admin code. Please leave admin code empty if you are a student." 
      end
    else
      @user.is_admin = false
      @user.valid?
    end 
    if @user.errors.size == 0
      @user.save
      log_in @user
      redirect_to root_url, notice: 'User was successfully created.'
    else    
      render :new
    end
  end
  
    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        redirect_to root_url, notice: "User was successfully updated."
      else
        render :edit
      end
    end

  # DELETE /users/1
  def destroy
    if current_user.is_admin?
      # commented out this if block because admins should not be able to delete 
      # themselves or other admins
      # if @user == current_user
      #   log_out
      # end
      if  !@user.is_admin?
        @user.destroy
      end 
      redirect_to users_url, notice: 'User was successfully destroyed.'
    else
      redirect_to root_url, notice: 'You do not have permission to delete users.'
    end
  end

  def regenerate_password
    @user = User.find(params[:id])
    new_password = @user.reset_password
    if(@user.update(password: new_password, password_confirmation: new_password))
      flash[:notice] = "#{@user.name}'s new password is #{new_password}"
      redirect_to root_url
    end
  end

  def confirm_delete
    @user = User.find(params[:id])
  end 

  def accept_team_invite
    team_status = JoinTeamStatus.find_by(team_id: params[:team_id], user_id: params[:user_id])
    team_status.update_attribute(:status, 1)
    redirect_to root_url, notice: "You have successfully joined team #{team_status.team.team_name}."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
    
    # Only allow a trusted parameter "white list" through.
    # Should use later (ignoring this for now)
    def user_params
      params.require(:user).permit(:first_name, :last_name, :admin_code, :email, :password, :password_confirmation)
    end

  private
  def sort_column
    params[:sort] || "first_name"
  end
  
  def sort_direction
    params[:direction] || "asc"
  end

end
