require 'mash'

class Hash
  # reimplem of ruby 2.4 transform_values
  if RUBY_VERSION < '2.4'
    def transform_values
      Hash[
        map do |k, v|
          [k, (yield v)]
        end
      ]
    end
  end
end

class Object
  def convert_to_hash
    has_to_h = ->(x) { x.respond_to?(:to_h) }
    case self
    when String, Numeric, TrueClass, FalseClass
      self
    when Symbol
      to_s
    when Hash
      keys.each_with_object({}) do |key, hash|
        hash[key.to_s] = self[key].convert_to_hash
      end
    when Array # here we suppose array of scalar
      map(&:convert_to_hash)
    when has_to_h
      to_h
    else
      raise "Can't convert #{inspect} to a hash"
    end
  end
end

module HomeAssistant
  module Generator
    # can be prepended by any class with properties hash
    module Properties
      attr_reader :properties

      def initialize(*args)
        @properties = {}
        super
      end

      def to_h
        properties.convert_to_hash
      end
    end
  end
end
