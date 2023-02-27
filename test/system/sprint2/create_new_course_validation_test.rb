require "application_system_test_case"
# Acceptance Criteria:
# 1. Given that I am an admin, I should be able to create a course

class CreateNewCourseValidationTest < ApplicationSystemTestCase
    # Test that Team cannot be created with a already used Team Code (1)
    def test_create_invalid_course
      # create professor 
      prof = User.create(email: 'msmucker@uwaterloo.ca', first_name: 'Mark', last_name: 'Smucker', is_admin: true, password: 'professor', password_confirmation: 'professor')
      course = Course.create(course_name: 'Math', course_code: 'N2L3K7', admin: prof)
      visit root_url
      login 'msmucker@uwaterloo.ca', 'professor'
      assert_current_path root_url
  
      # create new team
      click_on "Add Course"
      
      fill_in "Course name", with: "Math"
      fill_in "Course code", with: "N2L3K7"
      not_created_course_code = find_field("course[course_code]").value
      not_created_course_name = find_field("course[course_name]").value
      click_on "Create Course"
      assert_text "Course code has already been taken"
      assert_text "Course name has already been taken"
    end
  end