class Project < ApplicationRecord
  validates_presence_of :title, message: 'Title field mising'
end
