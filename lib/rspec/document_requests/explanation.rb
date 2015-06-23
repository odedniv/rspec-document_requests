module RSpec
  module DocumentRequests
    class Explanation
      class Side
        attr_accessor :parameters, :headers

        def initialize
          @parameters = {}
          @headers = {}
        end

        def parameter(name, *args)
          @parameters[name] = Request::Parameter.new(*args)
        end

        def header(name, *args)
          @headers[name] = Request::Parameter.new(*args)
        end
      end

      attr_accessor :message

      def initialize
        @request = Side.new
        @response = Side.new
      end

      def request(&block)
        @request.instance_eval(&block) if block_given?
        @request
      end

      def response(&block)
        @response.instance_eval(&block) if block_given?
        @response
      end
    end
  end
end
