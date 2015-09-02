ENV['RACK_ENV'] = 'test'
require("rspec")
require("pg")
require("sinatra/activerecord")


require("bundler/setup")
Bundler.require(:default, :test)
set(:root, Dir.pwd())

require('capybara/rspec')
Capybara.app = Sinatra::Application
set(:show_exceptions, false)
require('./app')

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.color = true
  config.after(:each) do
    Character.all().each() do |character|
      character.destroy()
    end
    Quest.all().each() do |quest|
      quest.destroy()
    end
    Scene.all().each() do |scene|
      scene.destroy()
    end
    User.all().each() do |user|
      user.destroy()
    end
    Observation.all().each() do |observation|
      observation.destroy()
    end
  end
end
