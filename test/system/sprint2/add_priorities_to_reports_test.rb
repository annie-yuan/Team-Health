require "application_system_test_case"

# Acceptance Criteria: 
# 1. As a student, I can indicate a certain priority on my submitted report so that others can see   how urgent it is
# 2. As a user, I can view the priority of reports I am allowed to view
#    This acceptance criteria is tested in ./add_student_views_for_reports_test.rb

class AddPrioritiesToReportsTest < ApplicationSystemTestCase
  setup do
    # create prof, team, and user
    @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
    @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', course: @course)
    @bob = User.create(email: 'bob@uwaterloo.ca', first_name: 'Bob', last_name: 'Smith', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @bob.teams << @team
    @bob.save!
    @steve = User.create(email: 'steve@uwaterloo.ca', first_name: 'Steve', last_name: 'Jones', is_admin: false, password: 'testpassword', password_confirmation: 'testpassword')
    @steve.teams << @team
    @steve.save!
  end
  
  # comment out since we are not using reports 
  # def test_submit_priorities
  #   visit root_url 
  #   login 'bob@uwaterloo.ca', 'testpassword'
    
  #   click_on "Submit a Report"
    
  #   # Create report with urgent priority
  #   select "Steve", from: "Reportee"
  #   select "Urgent", from: "Priority"
  #   fill_in "Description", with: "URGENT"
  #   click_on "Submit report"
    
  #   click_on "Submit a Report"
    
  #   # Create report with medium priority
  #   select "Steve", from: "Reportee"
  #   select "Medium", from: "Priority"
  #   fill_in "Description", with: "MEDIUM"
  #   click_on "Submit report"
    
  #   click_on "Submit a Report"
    
  #   # Create report with low priority
  #   select "Steve", from: "Reportee"
  #   select "Low", from: "Priority"
  #   fill_in "Description", with: "LOW"
  #   click_on "Submit report"
    
  #   Report.all.each do |report|      
  #     assert_equal(@bob.id, report.reporter_id)
  #     assert_equal(@steve.id, report.reportee_id)
      
  #     if report.description == 'URGENT'
  #       assert_equal(0, report.priority)
  #     elsif report.description == 'MEDIUM'
  #       assert_equal(1, report.priority)
  #     else
  #       assert_equal(2, report.priority)
  #     end
  #   end
  # end
  
  # def test_view_reports_as_professor
  #   Report.create(reporter_id: @bob.id, reportee_id: @steve.id, description: '0', priority: 0)
  #   Report.create(reporter_id: @steve.id, reportee_id: @bob.id, description: '1', priority: 1)
  #   Report.create(reporter_id: @steve.id, reportee_id: @bob.id, description: '2', priority:2)

  #   visit root_url 
  #   login 'msmucker@uwaterloo.ca', 'professor'

  #   click_on "Reports"
  #   assert_current_path reports_url
  #   assert_text 'Urgent'
  #   assert_text 'Medium'
  #   assert_text 'Low'
  # end
  
end