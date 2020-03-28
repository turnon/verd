require 'rails-erd'
spec = Gem::Specification.find_by_name 'rails-erd'
load "#{spec.gem_dir}/lib/rails_erd/tasks.rake"

namespace :verd do
  task :assign_source_location do
    ActiveRecord::Base.descendants.each do |klass|
      klass.source_location = ActiveSupport::Dependencies.loaded_model_paths[klass.name.underscore]
    end
  end

  task :generate => ['erd:options', 'erd:load_models', 'assign_source_location'] do
    g = Verd::Graph.new
    #pp g.links
    #pp g.nodes
    #pp g.categories
    puts g.to_json
    g.write_html
    #pp ActiveSupport::Dependencies.loaded_model_paths
  end
end

task :verd => "verd:generate"
