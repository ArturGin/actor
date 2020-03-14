# frozen_string_literal: true

class Actor
  # Represents the result of an action.
  class Context
    def self.to_context(data)
      return data if data.is_a?(self)

      new(data)
    end

    def initialize(data = {})
      @data = data.dup
    end

    def ==(other)
      other.class == self.class && data == other.data
    end

    def inspect
      "<ActorContext #{data.inspect}>"
    end

    def fail!(context = {})
      merge!(context)
      data[:failure?] = true
      raise Actor::Failure, self
    end

    def succeed!(context = {})
      merge!(context)
      data[:failure?] = false
      raise Actor::Success, self
    end

    def success?
      !failure?
    end

    def failure?
      data.fetch(:failure?, false)
    end

    def merge!(context)
      data.merge!(context)

      self
    end

    def key?(name)
      data.key?(name)
    end

    def [](name)
      data[name]
    end

    # Redefined here to override the method on `Object`.
    def display
      data.fetch(:display)
    end

    protected

    attr_reader :data

    private

    # rubocop:disable Style/MethodMissingSuper
    def method_missing(name, *arguments, **)
      if name =~ /=$/
        key = name.to_s.sub('=', '').to_sym
        data[key] = arguments.first
      else
        data[name]
      end
    end
    # rubocop:enable Style/MethodMissingSuper

    def respond_to_missing?(*_arguments)
      true
    end

    def context_get(key)
      data[key]
    end

    def context_set(key, value)
      data[key] = value
    end
  end
end
