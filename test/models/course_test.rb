require 'test_helper'
require 'date'
class CourseTest < ActiveSupport::TestCase
  include FeedbacksHelper
  setup do
    @prof = User.create(email: 'charles@uwaterloo.ca', password: 'banana', password_confirmation: 'banana', first_name: 'Charles', last_name: 'Dion', is_admin: true)
  end

  def test_create_course_invalid_course_code
    course = Course.new(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    course.save!
    course2 = Course.new(course_name: 'Physics', course_code: 'N2L3K7', admin: @prof)
    assert_not course2.valid?
  end

  def test_create_course_invalid_course_name
    course = Course.new(course_name: 'Math', course_code: 'N2L3K7', admin: @prof)
    course.save!
    course2 = Course.new(course_name: 'Math', course_code: 'N2L3K8', admin: @prof)
    assert_not course2.valid?
  end

  def test_create_course_invalid_course_name_length
    course = Course.new(course_name: 'asjkdhakjshdajsdhkjashdfkajsdhkjashdkjsadhfkj' , course_code: 'N2L3K7', admin: @prof)
    refute course.valid?, 'Course name is too long (maximum is 40 characters)'
    assert_not_nil course.errors[:course_name]
  end

  def test_create_course_blank_course_name
    course = Course.new(course_code: 'N2L3K7', admin: @prof)
    assert_not course.valid?
    assert_not_nil course.errors[:course_name]
  end

  def test_create_course_blank_course_code
    course = Course.new(course_name: 'Math', admin: @prof)
    assert_not course.valid?
    assert_not_nil course.errors[:course_name]
  end
end
