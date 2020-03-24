module Verd
  class Railtie < Rails::Railtie
    rake_tasks do
      load "verd/tasks.rake"
    end
  end
end
