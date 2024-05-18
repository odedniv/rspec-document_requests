module RSpec
  module DocumentRequests
    class Explanation
      class Side
        attr_accessor :message, :parameters, :headers

        def initialize
          @parameters = {}
          @headers = {}
        end

        def parameter(name, ...)
          @parameters[name] = Request::Parameter.new(...)
        end

        def header(name, ...)
          @headers[name] = Request::Parameter.new(...)
        end
      end

      def initialize
        @request = Side.new
        @response = Side.new
      end

      def self.build_side(side)
        define_method(side) do |message = nil, &block|
          instance = instance_variable_get(:"@#{side}")
          instance.message = message if message
          instance.instance_eval(&block) if block
          instance
        end
      end

      build_side :request
      build_side :response
    end
  end
end
