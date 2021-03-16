class Test < ApplicationRecord
  has_many :comments, through: :tasks
  has_many :participants
  has_many :meetings
  has_many :attachments, as: :attachable
end
