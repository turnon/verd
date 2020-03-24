class ActiveRecord::Base
  class << self
    attr_accessor :source_location, :model_validity

    def source_dir
      return @source_dir if @source_dir
      path = name.split(/::/)
      path.pop
      @source_dir = "/#{path.map(&:underscore).join('/')}"
    end

    def human_attribute_names
      attribute_names.each_with_object({}){ |attr, h| h[attr] = human_attribute_name(attr) }
    end

  end
end
