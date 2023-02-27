require "application_system_test_case"
# Acceptance Criteria:
# 1. As a student, I am able to submit a feedback with a priority
# 2. As a professor, I am able to view an individual team's priority for a time period
# 3. As a professor, I am able to view overall priority for all team's summary view

class AddPriorityToFeedbacksTest < ApplicationSystemTestCase
  include FeedbacksHelper
  
  setup do 
    @user = User.new(email: 'test@uwaterloo.ca', password: '123456789', password_confirmation: '123456789', first_name: 'Adam', last_name: 'test1', is_admin: false)
    @user2 = User.new(email: 'test2@uwaterloo.ca', password: '1234567891', password_confirmation: '1234567891', first_name: 'Adam2', last_name: 'test2', is_admin: false)
    @user10 = User.new(email: 'test10@uwaterloo.ca', password: '1234567891', password_confirmation: '1234567891', first_name: 'Adam10', last_name: 'test10',  is_admin: false)
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker',  is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @user.save!
    @user2.save!
    @user10.save!
    @user.join_team_statuses.create(team: @team, status: 1)
    @user2.join_team_statuses.create(team: @team, status: 1)
    @user10.join_team_statuses.create(team: @team, status: 1)
    
    @week_range = week_range(2021, 7)
    #sets the app's date to week of Feb 15 - 21, 2021 for testing
    travel_to Time.new(2021, 02, 15, 06, 04, 44)
  end 
  
  def test_create_feedback_with_no_priority
    #Passes acceptance criteria 1: Student submits a feedback with no user selected priority, instead the default value for priority is 2, meaning 'low' priority
    visit root_url
    login 'test@uwaterloo.ca', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 5, :from => "Collaboration score"
    select 5, :from => "Communication score"
    select 5, :from => "Time management score"
    select 5, :from => "Problem solving score"
    select 5, :from => "Knowledge of roles score"
    fill_in "feedback_comments", with: "I did not select a priority, default of low set"
    click_on "Create Feedback"
    assert_current_path root_url
    assert_text "Feedback was successfully created."
  end 
  
  def test_create_feedback_with_selected_priority
    #Passes acceptance criteria 1: Student submits a feedback with a selected priority
    visit root_url
    login 'test@uwaterloo.ca', '123456789'
    assert_current_path root_url
    
    click_on "Submit for"
    
    select 5, :from => "Collaboration score"
    select 5, :from => "Communication score"
    select 5, :from => "Time management score"
    select 5, :from => "Problem solving score"
    select 5, :from => "Knowledge of roles score"
    select "High", :from => "Priority"
    # select "Urgent", :from => "Priority"
    fill_in "feedback_comments", with: "I selected a priority, it's URGENT"
    click_on "Create Feedback"
    assert_current_path root_url
    assert_text "Feedback was successfully created."
  end
  
  def test_professor_individual_team_priority_view_timeperiod
    #Passes acceptance criteria 2: As a professor, I am able to view an individual team's priority for a time period

    feedback = save_feedback(5,5,5,5,5,5, "Week 9 data 1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team, 0)
    feedback2 = save_feedback(5,5,5,5,5,5, "Week 9 data 2", @user2, DateTime.civil_from_format(:local, 2021, 3, 3), @team, 2)
    feedback3 = save_feedback(5,5,5,5,5,5, "Week 7 data 1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team, 1)
    feedback4 = save_feedback(5,5,5,5,5,5, "Week 7 data 2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    click_on "Math"
    click_on 'Details'
    assert_current_path team_path(@team)
    
    within('#2021-7') do
      assert_text 'Feb 15, 2021 to Feb 21, 2021'
      assert_text 'Medium'
      assert_text 'Low'
      assert_text 'Week 7 data 1'
      assert_text 'Week 7 data 2'
      assert_text '2021-02-15'
      assert_text '2021-02-16'
    end
    within('#2021-9') do
      assert_text 'Mar 1, 2021 to Mar 7, 2021'
      assert_text 'Urgent'
      assert_text 'Low'
      assert_text 'Week 9 data 1'
      assert_text 'Week 9 data 2'
      assert_text '2021-03-01'
      assert_text '2021-03-03'
    end
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_urgent_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 1, professor should see a team's overall priority as "High" under team Urgency/Intervention column if at least one student gave a priority of "urgent" for feedback
    
    feedback1 = save_feedback(5,5,5,5,5,5, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team, 0)
    feedback2 = save_feedback(4,4,4,4,4,4, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 1)
    feedback3 = save_feedback(3,3,3,3,3,3, "Data2", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    
    click_on "Math"
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'High'
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_medium_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 2, professor should see a team's overall priority as "Medium" under team Urgency/Intervention column if at least 1/3 of student give a priority of "medium" for feedback
    
    feedback4 = save_feedback(5,5,5,5,5,5, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team, 1)
    feedback4 = save_feedback(4,4,4,4,4,4, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    feedback6 = save_feedback(2,2,2,2,2,2, "Data3", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    
    click_on "Math"
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'Medium'
  end 
  
  def test_professor_summary_team_priority_view_timeperiod_low_status
    #Passes acceptance criteria 3: As a professor, I am able to view overall priority for all team's summary view
    #Case 3, professor should see a team's overall priority as "Low" under team Urgency/Intervention column if no student has selected "Urgent" AND if 1/3 of feedbacks are not "Medium" priority
    
    feedback4 = save_feedback(5,5,5,5,5,5, "Data1", @user, DateTime.civil_from_format(:local, 2021, 2, 15), @team, 2)
    feedback4 = save_feedback(4,4,4,4,4,4, "Data2", @user2, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    feedback6 = save_feedback(2,2,2,2,2,2, "Data3", @user10, DateTime.civil_from_format(:local, 2021, 2, 16), @team, 2)
    
    visit root_url 
    login 'msmucker@uwaterloo.ca', 'professor'
    assert_current_path root_url 
    
    click_on "Math"
    assert_text 'Current Week: ' + @week_range[:start_date].strftime('%b %-e, %Y').to_s + " to " + @week_range[:end_date].strftime('%b %-e, %Y').to_s
    assert_text 'Low'
  end 
  
end
