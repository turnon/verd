require "verd/version"
require "verd/railtie" if defined? Rails
require "verd/active_record_base"
require "verd/dependencies"
require "rails_erd/domain"

module Verd

  module Domain
    attr_reader :domain

    def initialize
      @domain = RailsERD::Domain.generate
    end

    def relations
      @relations ||= domain.relationships.each_with_object({}) do |rel, rs|
        next if rel.destination.model.nil? || rel.source.model.nil?
       rs[[rel.source.model, rel.destination.model]] = rel
      end.values.sort_by do |rel|
        [rel.source.model.name, rel.destination.model.name]
      end
    end

    def models
      @models ||= relations.each_with_object(Set.new) do |rel, s|
        s << rel.destination.model << rel.source.model
      end.sort_by(&:name)
    end

    def to_h
      {nodes: nodes, links: links, categories: categories}
    end

    def to_json
      JSON.pretty_generate(to_h)
    end

    def to_html
      tmpl = File.join(__dir__, 'verd', 'template.html')
      File.read(tmpl).sub(/\/\/start-sub.*\/\/end-sub/m, to_json)
    end

    def write_html
      name = "verd.#{self.class.name.split(/::/).last.underscore}.html"
      path = File.join(Rails.root.to_s, name)
      File.open(path, 'w'){ |f| f.puts to_html }
    end
  end

  class ModelGraph
    include Domain

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
      relations.map do |rel|
        {source: rel.source.model.name, target: rel.destination.model.name}
      end
    end

    def categories
      plain_categories.map do |d|
        {name: d}
      end
    end

    private

    def plain_categories
      @categories ||= models.each_with_object(Set.new) do |m, s|
        s << m.source_dir
      end.sort
    end
  end

  class DetailGraph
    include Domain

  end

end
