class Option < ApplicationRecord
  validates_presence_of :admin_code  
  validates_length_of :admin_code, maximum: 10
  validate :code_unique
  
  def code_unique 
    if Team.exists?(team_code: self.admin_code)
      errors.add(:admin_code, 'not unique')
    end
  end
  
  def generate_admin_code(length = 6)
    # Taken from https://stackoverflow.com/questions/88311/how-to-generate-a-random-string-in-ruby
    admin_code = rand(36**length).to_s(36).upcase
    
    while Team.exists?(team_code: admin_code) or admin_code.size != length
      admin_code = rand(36**length).to_s(36).upcase
    end      
    
    self.admin_code = admin_code.upcase
    self.save
  end
end
