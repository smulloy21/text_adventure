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
end
