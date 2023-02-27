require "application_system_test_case"

# Acceptance Criteria:
# 1. Instructor should be able to send existing users invitation to the team.
# 2. Instructor should not be able to add user that is already in another team in the course
# 3. Instructor should not be able to add a user that is already added to the team
# 4. Instructor should not be able to send invite to pending user. 
# 5. Instructor should not be able to add user that has not signed up.
# 6. Users should be able to accept invitation from instructor.

class AddMemberToTeamTest < ApplicationSystemTestCase
    setup do     
        @prof = User.create(email: 'msmucker@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Test', is_admin: true)
        @user1 = User.create(email: 'charles2@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles1', last_name: 'Test1', is_admin: false)
        @user1.save!
        @user2 = User.create(email: 'charles3@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles2', last_name: 'Test2', is_admin: false)
        @user2.save!
        @user3 = User.create(email: 'charles4@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles3', last_name: 'Test3', is_admin: false)
        @course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
        @team = Team.new(team_code: 'Code', team_name: 'Team 1', course: @course)
        @team.save!     
        @user1.join_team_statuses.create(team: @team, status: 1)
        @user2.join_team_statuses.create(team: @team, status: 1)
        @team.course.users = [@user1, @user2] 
        visit root_url
        login 'msmucker@uwaterloo.ca', 'banana'
    end

    def test_add_user_to_team
        user3 = User.create(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'cathy', last_name: 'pham', is_admin: false)
        click_on 'Manage Teams'
        fill_in "user_email", with: "cathy@uwaterloo.ca"
        click_on "Add Members"
        assert_text "Successfully invited #{user3.name} to #{@team.team_name}."
    end 

    def test_add_user_to_another_team_in_course
        user3 = User.create(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'cathy', last_name: 'pham', is_admin: false)
        team2 = Team.new(team_code: 'Code2', team_name: 'Team 2', course: @course)
        team2.save
        user3.join_team_statuses.create(team: team2, status: 1)
        @course.users << user3

        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathy@uwaterloo.ca"
            click_on "Add Members"
        end
        assert_text "#{user3.name} is already in #{team2.team_name} for #{team2.course.course_name}."
    end

    def test_add_already_added_user_to_team
        user3 = User.create(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'cathy', last_name: 'pham', is_admin: false)
        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathy@uwaterloo.ca"
            click_on "Add Members"
        end
        click_on "Logout"

        login 'cathy@uwaterloo.ca', 'banana'
        click_on 'Join'
        click_on "Logout"

        visit root_url
        login 'msmucker@uwaterloo.ca', 'banana'
        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathy@uwaterloo.ca"
            click_on "Add Members"
        end
        assert_text "#{user3.name} is already added to the team."
    end

    def test_add_pending_user
        user3 = User.create(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'cathy', last_name: 'pham', is_admin: false)
        user3.join_team_statuses.create(team: @team, status: 0)
        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathy@uwaterloo.ca"
            click_on "Add Members"
        end
        assert_text "An invite to #{user3.name} has already been sent."
    end
    
    def test_add_not_existed_user
        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathypham@uwaterloo.ca"
            click_on "Add Members"
        end
        assert_text "There is no user with cathypham@uwaterloo.ca"
    end

    def test_user_accept_team_invite
        user3 = User.create(email: 'cathy@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'cathy', last_name: 'pham', is_admin: false)
        click_on 'Manage Teams'
        within('#team' + @team.id.to_s) do
            fill_in "user_email", with: "cathy@uwaterloo.ca"
            click_on "Add Members"
        end
        click_on "Logout"
        login 'cathy@uwaterloo.ca', 'banana'
        click_on 'Join'
        assert_text "You have successfully joined team #{@team.team_name}."
        assert_current_path root_url
    end
    
end