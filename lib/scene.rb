require('pry')
class Scene < ActiveRecord::Base
  belongs_to(:quest)
  has_many(:observations)

  define_method(:options) do
    options = []
    Scene.all.each do |scene|
      if scene.previous_scene == self.id
        options.push(scene)
      end
    end
    options
  end

  define_method(:required_observations?) do
    required = []
    observations.each do |observation|
      if observation.required == true
        required.push(observation.id)
      end
    end
    required
  end

  define_method(:render_menu) do
    s = ''
    self.options.each do |option|
      s << '<li><a href="/' + self.quest.user_id.to_s + '/scenes/' + option.id.to_s + '/edit">' + option.name + '</a></li>'
      s << '<ul>'
      s << (option.render_menu())
      s << '</ul>'
    end
    s
  end
end
