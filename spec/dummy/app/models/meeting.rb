class Meeting < ApplicationRecord
  belongs_to :project
  has_many :participants
end
