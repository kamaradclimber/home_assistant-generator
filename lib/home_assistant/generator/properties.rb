class Hash
  # reimplem of ruby 2.4 transform_values
  if RUBY_VERSION < '2.4'
    def transform_values
      Hash[
        self.map do |k, v|
          [k, (yield v)]
        end
      ]
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
        has_to_h = ->(x) { x.respond_to?(:to_h) }
        properties.transform_values do |value|
          case value
          when String, Integer, TrueClass, FalseClass
            value
          when Symbol
            value.to_s
          when has_to_h
            value.to_h
          when Array
            raise NotImplementedError, 'should be implemented for arrays as well!'
          else
            raise "Can't convert #{value} to a hash"
          end
        end
      end
    end
  end
end
