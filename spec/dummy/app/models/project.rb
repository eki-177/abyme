class Project < ApplicationRecord
  include Abyme::Model
  
  has_many :tasks, inverse_of: :project, dependent: :destroy
  has_many :comments, through: :tasks
  has_many :participants
  
  abyme_for :tasks
  abyme_for :participants

  validates :title, presence: true
  validates :description, presence: true
end
