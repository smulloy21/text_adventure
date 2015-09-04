ENV['RACK_ENV'] = 'development'
require 'active_record'
require('bundler/setup')
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
require('sinatra/reloader')
also_reload('./lib/**/*.rb')

require('pry')

get('/') do
  erb(:index)
end

get('/about') do
  erb(:about)
end

delete('/exterminate') do
  Quest.all.each do |quest|
    quest.destroy()
  end
  redirect('/')
end

get('/login') do
  name = params.fetch("name")
  password = params.fetch("password")
  if User.find_user_login(name, password) != nil
    @user = User.find_user_login(name, password)
    redirect('/users/' + @user.id.to_s)
  else
    erb(:index)
  end
end

post('/login/new') do
  name =  params.fetch("email")
  password = params.fetch("password")
  password2 = params.fetch("password2")
  if password2 != password
    redirect('/')
    #pass an error message
  end
  @user = User.create({:name => name, :password => password})
  redirect('/users/' + @user.id.to_s)
end

get('/users/:user_id') do
  @user = User.find(params.fetch('user_id').to_i)
  erb(:character)
end

############################## ADMIN ##################################

get('/:user_id/admin') do
  @user = User.find(params.fetch('user_id').to_i)
  @quests = @user.quests
  erb(:admin)
end

post('/:user_id/quests/new') do
  @user = User.find(params.fetch('user_id').to_i)
  name = params.fetch('name')
  synopsis = params.fetch('synopsis')
  Quest.create({:name => name, :user_id => @user.id, :rating => 0, :times_rated => 0, :synopsis => synopsis})
  redirect('/' + @user.id.to_s + '/admin')
end

get('/:user_id/quests/:id/edit') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('id').to_i)
  @scenes = @quest.scenes.sort_by(&:created_at)
  erb(:quest_edit)
end

patch('/:user_id/quests/:id/edit_name') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('id').to_i)
  name = params.fetch('name')
  @quest.update({:name => name})
  redirect('/' + @user.id.to_s + '/quests/' + @quest.id.to_s + '/edit')
end

patch('/:user_id/quests/:id/edit_description') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('id').to_i)
  synopsis = params.fetch('synopsis')
  @quest.update({:synopsis => synopsis})
  redirect('/' + @user.id.to_s + '/quests/' + @quest.id.to_s + '/edit')
end

delete('/:user_id/quests/:id/delete') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('id').to_i)
  @quest.scenes.each do |scene|
    scene.destroy()
  end
  @quest.destroy()
  redirect('/' + @user.id.to_s + '/admin')
end

post('/:user_id/scenes/new') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('quest_id').to_i)
  keyword = "START"
  name = params.fetch('name')
  description = params.fetch('description')
  if params.fetch('background') != nil
    background = params.fetch('background')
  else
    background = nil
  end
  Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => nil, :background => background})
  redirect('/' + @user.id.to_s + '/quests/' + @quest.id.to_s + '/edit')
end

post('/:user_id/scenes/add') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('quest_id').to_i)
  previous_id = params.fetch('previous_scene').to_i
  keyword = params.fetch('keyword')
  params.fetch('name') != "" ? name = params.fetch('name') : name = params.fetch('keyword')
  description = params.fetch('description')
  if params.fetch('background') != nil
    background = params.fetch('background')
  else
    background = nil
  end
  @scene = Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => previous_id, :background => background})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.previous_scene.to_s + '/edit')
end

get('/:user_id/scenes/:id/edit') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  erb(:scene_edit)
end

patch('/:user_id/scenes/:id/edit_name') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  name = params.fetch('name')
  @scene.update({:name => name})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
end

patch('/:user_id/scenes/:id/edit_description') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  description = params.fetch('description')
  @scene.update({:description => description})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
end

patch('/:user_id/scenes/:id/edit_bg') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  background = params.fetch('background')
  @scene.update({:background => background})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
end

delete('/:user_id/scenes/:id/delete') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  @quest = Quest.find(@scene.quest_id)
  @scene.options.each do |option|

    Scene.find(option.id).destroy()
  end
  @scene.destroy()
  redirect(''/' + @user.id.to_s + /quests/' + @quest.id.to_s + '/edit')
end

post('/:user_id/scenes/:id/add_observation') do
  @user = User.find(params.fetch('user_id').to_i)
  @scene = Scene.find(params.fetch('id').to_i)
  name = params.fetch('name')
  keyword = params.fetch('keyword')
  description = params.fetch('description')
  Observation.create({:name => name, :keyword => keyword, :description => description, :scene_id => @scene.id})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
end

####################### PLAY QUEST #################################

get('/characters/:id') do
  @character = Character.find(params.fetch('id').to_i)
  @user = @character.user
  @quests = Quest.all().sort_by(&:rating).reverse
  @@div = ""
  erb(:quest)
end

post('/characters/new') do
  @user = User.find(params.fetch('user_id').to_i)
  name = params.fetch('name')
  @character = Character.create({:name => name, :user_id => @user.id})
  @quests = Quest.all.sort_by(&:rating)
  @@div = ""
  erb(:quest)
end

get('/users/:user_id/delete_character/:character_id') do
  @character = Character.find(params.fetch('character_id').to_i)
  @user = User.find(params.fetch('user_id').to_i)
  @character.destroy()
  redirect('/users/' + @user.id.to_s)
end

get('/characters/:character_id/scenes/:id') do
  @character = Character.find(params.fetch('character_id').to_i)
  @user = @character.user
  @scene = Scene.find(params.fetch('id').to_i)
  if @scene.background != nil
    @background = @scene.background
  else
    @background = 'http://img06.deviantart.net/93d4/i/2009/022/3/e/steampunk_octopus_by_raybender.jpg'
  end
  erb(:scene)
end

get('/characters/:character_id/scenes/:id/interpret') do
  @character = Character.find(params.fetch('character_id').to_i)
  @user = @character.user
  destructive_verbs = ['break', 'kick', 'punch', 'hit', 'pick up', 'pick', 'screw', 'fuck', 'bodyslam', 'body slam', 'destroy', 'kill', 'maim', 'hurt', 'punt', 'dropkick', 'throw', 'beat up', 'shoot', 'slap', 'shatter', 'cut', 'strangle', 'suffocate', 'throttle']
  @scene = Scene.find(params.fetch('id').to_i)
  text = params.fetch('text')
  @scene.options.each do |option|
    if text.downcase.include?(option.keyword.downcase)
      @@div = ""
      redirect('/characters/' + @character.id.to_s + '/scenes/' + option.id.to_s)
    end
  end
  destructive_verbs.each do |verb|
    if text.downcase.include?(verb)
      @@div = "You can't " + verb + " that."
      redirect('/characters/' + @character.id.to_s + '/scenes/' + @scene.id.to_s)
    end
  end
  @scene.observations.each do |observation|
    if text.include?(observation.keyword)
      redirect('/characters/' + @character.id.to_s + '/scenes/' + @scene.id.to_s + '/observations/' + observation.id.to_s)
    end
  end
  if text.downcase.include?('back')
    @@div = ""
    redirect('/characters/' + @character.id.to_s + '/scenes/' + @scene.previous_scene.to_s)
  end
  @@div = "You can't do that."
  redirect('/characters/' + @character.id.to_s + '/scenes/' + @scene.id.to_s)
end

get('/characters/:character_id/scenes/:id/observations/:observation_id') do
  @character = Character.find(params.fetch('character_id').to_i)
  @user = @character.user
  @scene = Scene.find(params.fetch('id').to_i)
  @observation = Observation.find(params.fetch('observation_id'))
  @@div = @observation.description
  if @observation.required == true && @@can_continue.include?(@observation.id)
    @@can_continue.delete(@observation.id)
  end
  redirect('/characters/' + @character.id.to_s + '/scenes/' + @scene.id.to_s)
end

post('/characters/:character_id/scenes/:id/rating') do
  @character = Character.find(params.fetch('character_id').to_i)
  @user = @character.user
  quest = Quest.find(Scene.find(params.fetch('id').to_i).quest_id)
  times_rated = 1 + quest.times_rated
  rating = (params.fetch("rating").to_i) + quest.rating


  quest.update({:times_rated => times_rated, :rating => rating})

  redirect('/characters/' + @character.id.to_s)
end
