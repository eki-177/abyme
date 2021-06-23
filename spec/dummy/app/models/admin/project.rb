module Admin
  class Admin::Project < ApplicationRecord
    has_many :tasks, inverse_of: :project, dependent: :destroy
    has_many :comments, through: :tasks
    has_many :participants

    validates :title, presence: true
    validates :description, presence: true
  end
end
