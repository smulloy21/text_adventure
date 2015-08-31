class Scene < ActiveRecord::Base
  belongs_to(:quest)

  define_method(:options) do
    options = []
    Scene.all.each do |scene|
      if scene.previous_scene == self.id
        options.push(scene)
      end
    end
    options
  end
end
