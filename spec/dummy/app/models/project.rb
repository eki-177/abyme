class Project < ApplicationRecord
  include Abyme::Model

  has_many :tasks, inverse_of: :project, dependent: :destroy
  abymize :tasks, permit: [:description, :title]

  has_many :admin_tasks, class_name: "Admin::Task"
  abymize :admin_tasks, permit: [:description, :title], class_name: "Admin::Task"

  has_many :comments, through: :tasks

  has_many :participants
  has_many :meetings
  has_many :attachments, as: :attachable

  abymize :participants, permit: [:email, :name], allow_destroy: false
  abymize :tasks, permit: [:description, :title]
  abymize :meetings, allow_destroy: false
  abymize :attachments

  validates :title, presence: true
  validates :description, presence: true
end
