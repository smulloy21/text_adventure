class Quest < ActiveRecord::Base
  has_many(:scenes)
  belongs_to(:character)
end
