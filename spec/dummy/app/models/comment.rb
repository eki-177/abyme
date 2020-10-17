class Comment < ApplicationRecord
  belongs_to :task

  validates :content, presence: true
  validates :content, length: { minimum: 3 }
end
