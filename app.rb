ENV['RACK_ENV'] = 'development'
require 'active_record'
require('bundler/setup')
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
require ('pry')

get('/') do
  erb(:index)
end

get('/login') do
  name = params.fetch("login")
  password = params.fetch("password")
  if User.find_user_login(name, password) != nil
    @user = User.find_user_login(name, password)
    erb(:character)
  else
    erb(:index)
  end
end

post('/login/new') do
  name =  params.fetch("new_name")
  password1 = params.fetch("new_password1")
  password2 = params.fetch("new_password2")
  if password2 != password1
    redirect('/')
    #pass an error message
  end
  User.create({:name => name, :password => password1})
  erb(:character)
end

############################## ADMIN ##################################

get('/admin') do
  @quests = Quest.all
  erb(:admin)
end

post('/quests/new') do
  name = params.fetch('name')
  Quest.create({:name => name})
  redirect('/admin')
end

get('/quests/:id/edit') do
  @quest = Quest.find(params.fetch('id').to_i)
  @scenes = @quest.scenes.sort_by(&:created_at)
  erb(:quest_edit)
end

post('/scenes/new') do
  @quest = Quest.find(params.fetch('quest_id').to_i)
  keyword = "START"
  name = params.fetch('name')
  description = params.fetch('description')
  Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => nil})
  redirect('/quests/' + @quest.id.to_s + '/edit')
end

post('/scenes/add') do
  @quest = Quest.find(params.fetch('quest_id').to_i)
  previous_id = params.fetch('previous_scene').to_i
  keyword = params.fetch('keyword')
  name = params.fetch('name')
  description = params.fetch('description')
  Scene.create({:name => name, :keyword => keyword, :description => description, :quest_id => @quest.id, :previous_scene => previous_id})
  redirect('/quests/' + @quest.id.to_s + '/edit')
end

get('/scenes/:id/edit') do
  @scene = Scene.find(params.fetch('id').to_i)
  erb(:scene_edit)
end

patch('/scenes/:id/edit_name') do
  @scene = Scene.find(params.fetch('id').to_i)
  name = params.fetch('name')
  @scene.update({:name => name})
  redirect('/scenes/' + @scene.id.to_s + '/edit')
end

patch('/scenes/:id/edit_description') do
  @scene = Scene.find(params.fetch('id').to_i)
  description = params.fetch('description')
  @scene.update({:description => description})
  redirect('/scenes/' + @scene.id.to_s + '/edit')
end

delete('/scenes/:id/delete') do
  @scene = Scene.find(params.fetch('id').to_i)
  @quest = Quest.find(@scene.quest_id)
  @scene.options.each do |option|
    Scene.find(option.id).destroy()
  end
  @scene.destroy()
  redirect('/quests/' + @quest.id.to_s + '/edit')
end

####################### PLAY QUEST #################################

get('character/:id')

  erb(:quest)
end

post('/characters/new') do
  name = params.fetch('name')
  @character = Character.create({:name => name})
  @quests = Quest.all
  erb(:quest)
end

get('/scenes/:id') do
  @scene = Scene.find(params.fetch('id').to_i)
  erb(:scene)
end
