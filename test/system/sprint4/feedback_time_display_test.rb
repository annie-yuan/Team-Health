require "application_system_test_case"

# Acceptance Criteria:
# 1. As student, I should be able to see the time I have started a feedback
# 2. As a student, I should be able to see the time that I have submitted a feedback

class FeebackTimeDisplayTest < ApplicationSystemTestCase
  setup do
    @user = User.new(email: 'test@uwaterloo.ca', password: 'asdasd', password_confirmation: 'asdasd', first_name: 'Zac', last_name: 'Brown', is_admin: false)
    @user.save
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.join_team_statuses.create(team: @team, status: 1)
      
    # Time.zone = 'Pacific Time (US & Canada)'

    datetime =  Time.zone.parse("2021-3-21 23:30:00")
    feedback_time = Time.zone.parse("2021-3-20 23:30:00")
    travel_to datetime
  end 
    
  def test_time_displays
    visit root_url
    login 'test@uwaterloo.ca', 'asdasd'
    assert_current_path root_url
    click_on "Submit for"
    assert_text "Current System Time: 2021/03/21 23:30" #Acceptance criteria #1
    select 5, :from => "Collaboration score"
    select 5, :from => "Communication score"
    select 5, :from => "Time management score"
    select 5, :from => "Problem solving score"
    select 5, :from => "Knowledge of roles score"
    select "High", :from => "Priority"
    click_on "Create Feedback"
    assert_current_path root_url
    assert_text "Feedback was successfully created. Time created: 2021-03-21 23:30:00" #Acceptance criteria #2
  end 
  
end