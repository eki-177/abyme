class Project < ApplicationRecord
  include Abyme::Model
  
  has_many :tasks, inverse_of: :project, dependent: :destroy
  has_many :comments, through: :tasks
  has_many :participants
  
  abymize :tasks, permit: [:description, :title]
  abymize :participants, permit: [:email, :name]

  validates :title, presence: true
  validates :description, presence: true
end
