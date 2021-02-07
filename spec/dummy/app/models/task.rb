class Task < ApplicationRecord
  include Abyme::Model

  belongs_to :project
  has_many :comments, inverse_of: :task, dependent: :destroy

  abymize :comments, permit: :all_attributes
  # abymize :comments, permit: :all_attributes

  validates :title, presence: true
  validates :description, presence: true

  scope :done, -> { where(status: 'done') }
  scope :todo, -> { where(status: 'todo') }
end

