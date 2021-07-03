class Attachment < ApplicationRecord
  include Abyme::Model

  belongs_to :attachable, polymorphic: true
end
