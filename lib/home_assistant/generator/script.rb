require_relative 'component'

class Array
  def ===(value)
    # self is the pattern, value is the object we try to match
    return false unless value.is_a?(Array) && size == value.size
    zip(value).all? do |pattern, b|
      (pattern === b).tap do |res|
        puts "#{pattern.inspect} === #{b} => #{res}"
      end
    end
  end
end

module HomeAssistant
  module Generator
    class DSL
      class Script < Component

        def name_property
          :alias
        end

        def alias(value = nil)
          if value
            @alias = value
            properties[id]['alias'] ||= value
          end
          @alias
        end

        def id
          @alias.underscore.tap do |_id|
            properties[_id] ||= {}
          end
        end

        class SequenceAction
          def initialize(k, v)
            @k = k
            @v = v
          end

          def convert_to_hash
            { @k => @v }
          end
        end

        def method_missing(name, *args, &block)
          properties[id]['sequence'] ||= []
          parts = name.to_s.split('_')

          empty = -> (array) { array.is_a?(Array) && array.empty? }
          one_el = -> (array) { array.is_a?(Array) && array.one? }

          case [args, parts]
          when [empty, one_el]
            return super if parts.size.one?
          when [empty, Array]
            # there is ambiguity if parts has 3 elements
            component = parts.pop
            SequenceAction.new('service', "#{component}.#{parts.join('_')}")
          else
            raise 'Not implemented yet!'
          end.tap do |el|
            properties[id]['sequence'] << el if el.is_a?(SequenceAction)
          end
        end
      end
    end
  end
end
