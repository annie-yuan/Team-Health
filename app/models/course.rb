class Course < ApplicationRecord
  validates_length_of :course_name, maximum: 40
  validates_length_of :course_code, maximum: 26
  validates_uniqueness_of :course_name, :case_sensitive => false, :message => " has already been taken"
  validates_uniqueness_of :course_code, :case_sensitive => false
  validates_presence_of :course_name
  validates_presence_of :course_code
    
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'
  has_and_belongs_to_many :users
  has_many :teams
end
