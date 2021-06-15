class Project < ApplicationRecord
  include Abyme::Model

  has_many :tasks, inverse_of: :project, dependent: :destroy
  abymize :tasks, permit: [:description, :title]

  has_many :comments, through: :tasks
  has_many :participants
  # abymize :participants, permit: [:email, :name], allow_destroy: false
  has_many :meetings
  abymize :meetings, permit: [:start_time, :end_time]


  has_many :attachments, as: :attachable
  abymize :attachments

  validates :title, presence: true
  validates :description, presence: true
end
