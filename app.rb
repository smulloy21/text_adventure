ENV['RACK_ENV'] = 'development'
require 'active_record'
require('bundler/setup')
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
