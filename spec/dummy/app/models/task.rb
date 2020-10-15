class Task < ApplicationRecord
  include Abyme::Model

  belongs_to :project
  has_many :comments, inverse_of: :task, dependent: :destroy

  abyme_for :comments

  validates :title, presence: true
  validates :description, presence: true

  scope :done, -> { where(status: 'done') }
  scope :todo, -> { where(status: 'todo') }
end

