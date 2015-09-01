class User < ActiveRecord::Base
  validates(:name, :presence => true)
  validates(:name, uniqueness: true)
  has_many(:characters)


  define_singleton_method(:find_user_login) do |name, password|
    user_found = nil
    User.all.each do |user|
      if user.name == name && user.password == password
         user_found = user
      end
    end
    user_found
  end


end
