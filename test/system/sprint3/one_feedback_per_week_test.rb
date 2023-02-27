require "application_system_test_case"


class OneFeedbackPerWeekTest < ApplicationSystemTestCase
#as a student i should only be able to submit one feedback a week
      setup do
        @prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
        @team = Team.create(team_name: 'Test Team', team_code: 'TEAM01', user: @prof)
        @user = User.new(email: 'test@uwaterloo.ca', password: '123456789', first_name: 'Zac', last_name: 'Test', is_admin: false)
        @user.teams << @team
        @user.save!

        @week_range = week_range(2021, 7)
        #sets the app's date to week of Feb 15 - 21, 2021 for testing
        travel_to Time.new(2021, 02, 15, 06, 04, 44)
      end
  
    def button_gone_test
        feedback = save_feedback(10, "Team1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team, 0)
        visit root_url 
        login 'test@uwaterloo.ca', '123456789'
        assert_current_path root_url 
        assert_no_text "Submit Feedback & Rating for team"
    end

    def alreadysubmitted_message_test
        feedback = save_feedback(10, "Team1", @user, DateTime.civil_from_format(:local, 2021, 3, 1), @team, 0)
        visit root_url 
        login 'test@uwaterloo.ca', '123456789'
        assert_current_path root_url 
        visit new_feedback_url
        select "5", from: "Rating"
        select "Urgent", from: "Priority"
        fill_in "Comments", with: "This week has gone okay."
        click_on "Create Feedback"
        assert_current_path root_url 
        assert_text "You have already submitted feedback for this team this week."
    end
end