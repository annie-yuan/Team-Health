class JoinTeamStatus < ApplicationRecord
    belongs_to :team
    belongs_to :user
    validates :status, numericality: { in: 0..2 }
end
