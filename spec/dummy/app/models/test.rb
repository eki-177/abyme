class Test < ApplicationRecord
  include Abyme::Model

  has_many :comments, through: :tasks
  has_many :participants
  has_many :meetings
  has_many :attachments, as: :attachable
  abymize :attachments, permit: :all_attributes
end
