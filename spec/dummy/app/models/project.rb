class Project < ApplicationRecord
  include Abyme::Model

  has_many :tasks, inverse_of: :project, dependent: :destroy
  abymize :tasks, permit: [:description, :title]

  has_many :comments, through: :tasks
  abymize :comments, permit: :all_attributes

  has_many :participants
  # abymize :participants, permit: [:email, :name]

  validates :title, presence: true
  validates :description, presence: true
end
