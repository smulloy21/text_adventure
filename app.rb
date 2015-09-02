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

get('/login') do
  name = params.fetch("name")
  password = params.fetch("password")
  if User.find_user_login(name, password) != nil
    @user = User.find_user_login(name, password)
    erb(:character)
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
  Quest.create({:name => name, :user_id => @user.id})
  redirect('/' + @user.id.to_s + '/admin')
end

get('/:user_id/quests/:id/edit') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('id').to_i)
  @scenes = @quest.scenes.sort_by(&:created_at)
  erb(:quest_edit)
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
  Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => nil})
  redirect('/' + @user.id.to_s + '/quests/' + @quest.id.to_s + '/edit')
end

post('/:user_id/scenes/add') do
  @user = User.find(params.fetch('user_id').to_i)
  @quest = Quest.find(params.fetch('quest_id').to_i)
  previous_id = params.fetch('previous_scene').to_i
  keyword = params.fetch('keyword')
  name = params.fetch('name')
  description = params.fetch('description')
  @scene = Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => previous_id})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
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
  required = params.fetch('required')
  Observation.create({:name => name, :keyword => keyword, :description => description, :required => required, :scene_id => @scene.id})
  redirect('/' + @user.id.to_s + '/scenes/' + @scene.id.to_s + '/edit')
end

####################### PLAY QUEST #################################

get('/characters/:id') do
  @character = Character.find(params.fetch('id').to_i)
  @user = @character.user
  @quests = Quest.all()
  @@div = ""
  erb(:quest)
end

post('/characters/new') do
  @user = User.find(params.fetch('user_id').to_i)
  name = params.fetch('name')
  @character = Character.create({:name => name, :user_id => @user.id})
  @quests = Quest.all
  @@div = ""
  erb(:quest)
end

get('/scenes/:id') do
  @scene = Scene.find(params.fetch('id').to_i)
  @@can_continue = @scene.required_observations?
  erb(:scene)
end

get('/scenes/:id/interpret') do
  destructive_verbs = ['break', 'kick', 'punch', 'hit', 'pick up', 'pick']
  going_verbs = ['go', 'walk', 'jump', 'climb', 'slide', 'somersault', ]
  @scene = Scene.find(params.fetch('id').to_i)
  text = params.fetch('text')
  @scene.options.each do |option|
    going_verbs.each do |verb|
      if text.downcase.include?(verb) && text.downcase.include?(option.keyword.downcase)
        @@div = ""
        redirect('/scenes/' + option.id.to_s)
      end
    end
  end
  if text.downcase.include?('back')
    @@div = ""
    redirect('/scenes/' + @scene.previous_scene.to_s)
  end
  destructive_verbs.each do |verb|
    if text.downcase.include?(verb)
      @@div = "You can't " + verb + " that."
      redirect('/scenes/' + @scene.id.to_s)
    end
  end
  @scene.observations.each do |observation|
    if text.include?(observation.keyword)
      redirect('/scenes/' + @scene.id.to_s + '/observations/' + observation.id.to_s)
    end
  end
  @@div = "You can't do that."
  redirect('/scenes/' + @scene.id.to_s)
end

get('/scenes/:id/observations/:observation_id') do
  @scene = Scene.find(params.fetch('id').to_i)
  @observation = Observation.find(params.fetch('observation_id'))
  @@div = @observation.description
  if @observation.required == true && @@can_continue.include?(@observation.id)
    @@can_continue.delete(@observation.id)
  end
  redirect('/scenes/' + @scene.id.to_s)
end
