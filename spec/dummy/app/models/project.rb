class Project < ApplicationRecord
  has_many :tasks, inverse_of: :project, dependent: :destroy
  has_many :comments, through: :tasks
  has_many :participants
  has_many :meetings
  has_many :attachments, as: :attachable

  abymize :participants, permit: [:email, :name], allow_destroy: false
  abymize :meetings, allow_destroy: false
  abymize :attachments

  validates :title, presence: true
  validates :description, presence: true
end
