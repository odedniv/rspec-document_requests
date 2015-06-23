module RSpec
  module DocumentRequests
    class Request
      class Parameter
        attr_accessor :message, :required, :type, :value
        def initialize(message = nil, required: false, type: nil, value: nil)
          @message = message
          @required = required
          @type = type
          @value = value
        end
      end

      attr_reader :explanation, :example, :method, :path
      attr_reader :request_parameters, :request_headers
      attr_reader :response, :parsed_response, :response_parameters, :response_headers
      def initialize(explanation:, example:, method:, path:, request_parameters:, request_headers:, response:)
        @explanation    = explanation
        @example        = example
        @method         = method
        @path           = path
        @response       = response

        process_request_parameters(request_parameters)
        process_request_headers(request_headers)
        process_response_parameters
        process_response_headers
      end

      private

      def self.filter_values(name)
        define_method(name) do
          values = instance_variable_get(:"@#{name}")
          next values if values.nil?

          included_values = DocumentRequests.configuration.send(:"include_#{name}")
          excluded_values = DocumentRequests.configuration.send(:"exclude_#{name}")
          hidden_values = DocumentRequests.configuration.send(:"hide_#{name}")

          values.select! do |k, v|
            next false if included_values and included_values.exclude?(k)
            next false if excluded_values.include?(k)
            values[k].value = "..." if hidden_values.include?(k)
            true
          end
          values
        end
      end

      public

      filter_values :request_parameters
      filter_values :request_headers
      filter_values :response_parameters
      filter_values :response_headers

      private

      def process_request_parameters(parameters, prefix: nil)
        @request_parameters = {}
        process_parameters(request_parameters, @request_parameters, explanation: @explanation.request.parameters)
      end

      def process_request_headers(headers)
        @request_headers = {}
        headers.each do |name, value|
          @request_headers[name] = @explanation.request.headers[name] || Parameter.new
          @request_headers[name].value = value
        end
        @explanation.request.headers.each { |name, header| @request_headers[name] ||= header }
      end

      def process_response_parameters(parameters = nil)
        @parsed_response = DocumentRequests.configuration.response_parser.call(response)
        if @parsed_response
          @response_parameters = {}
          process_parameters(@parsed_response, @response_parameters, explanation: @explanation.response.parameters)
        end
      end

      def process_response_headers
        @response_headers = {}
        @response.headers.each do |name, value|
          @response_headers[name] = @explanation.response.headers[name] || Parameter.new
          @response_headers[name].value = value
        end
        @explanation.response.headers.each { |name, header| @response_headers[name] ||= header }
      end

      def process_parameters(input, output, explanation:, prefix: nil)
        input.each do |key, value|
          name = prefix ? "#{prefix}[#{key}]" : key
          if value.is_a?(Hash)
            process_parameters(value, output, explanation: explanation, prefix: name)
          else
            output[name] = explanation[name] || Parameter.new
            output[name].value = value
          end
        end
        if prefix.nil?
          explanation.each { |name, parameter| output[name] ||= parameter }
        end
      end
    end
  end
end
