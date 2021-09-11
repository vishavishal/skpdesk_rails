class Project < ApplicationRecord
  validates_presence_of :title, message: ' field missing'
  validates_presence_of :client, message: ' field missing'
  validates_presence_of :project_type, message: ' field missing'
end
