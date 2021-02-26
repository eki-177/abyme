class Task < ApplicationRecord
  include Abyme::Model

  belongs_to :project

  has_many :comments, inverse_of: :task, dependent: :destroy
  abymize :comments, permit: :all_attributes

  has_many :attachments, as: :attachable
  abymize :attachments, reject: [:name]

  validates :title, presence: true
  validates :description, presence: true

  scope :done, -> { where(status: 'done') }
  scope :todo, -> { where(status: 'todo') }
end

