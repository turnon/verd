require "verd/version"
require "verd/railtie" if defined? Rails
require "verd/active_record_base"
require "verd/dependencies"
require "rails_erd/domain"

module Verd

  class Graph
    attr_reader :domain

    def initialize
      @domain = RailsERD::Domain.generate
    end

    def relations
      @relations ||= domain.relationships.each_with_object({}) do |rel, rs|
        next if rel.destination.model.nil? || rel.source.model.nil?
       rs[[rel.destination.model, rel.source.model]] = rel
      end.values
    end

    def models
      @models ||= relations.each_with_object(Set.new) do |rel, s|
        s << rel.destination.model << rel.source.model
      end
    end

    def nodes
      models.map do |model|
        category = plain_categories.index(model.source_dir)
        {
          name: model.name,
          category: category
        }
      end
    end

    def links
      arr = []
      relations.each_with_index do |rel, i|
        arr << {
          id: i,
          source: rel.source.model.name,
          target: rel.destination.model.name
        }
      end
      arr
    end

    def categories
      plain_categories.map do |d|
        {name: d}
      end
    end

    def plain_categories
      @categories ||= models.each_with_object(Set.new) do |m, s|
        s << m.source_dir
      end.to_a
    end

    def to_h
      {nodes: nodes, links: links, categories: categories}
    end

    def to_json
      to_h.to_json
    end

    def to_html
      tmpl = File.join(__dir__, 'verd', 'template.html')
      File.read(tmpl).sub(/\/\/start-sub.*\/\/end-sub/m, to_json)
    end

    def write_html
      path = File.join Rails.root.to_s, 'verd.html'
      File.open(path, 'w'){ |f| f.puts to_html }
    end
  end
end