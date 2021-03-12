module Admin
  class Test < ApplicationRecord
    include Abyme::Model

    has_many :comments, through: :tasks
    has_many :participants
    abymize :participants, permit: [:email, :name]

    has_many :meetings
    has_many :attachments, as: :attachable
  end
end