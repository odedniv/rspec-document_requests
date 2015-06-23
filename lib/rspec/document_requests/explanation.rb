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
        return @request if not block_given?
        @request.instance_eval(&block)
      end

      def response(&block)
        return @request if not block_given?
        @response.instance_eval(&block)
      end
    end
  end
end
