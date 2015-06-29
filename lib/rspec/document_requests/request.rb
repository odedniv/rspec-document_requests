module RSpec
  module DocumentRequests
    class Request
      class Parameter
        attr_accessor :message, :required, :type, :value, :generated
        def initialize(message = nil, required: false, type: nil, value: nil, generated: false)
          @message = message
          @required = required
          @type = type
          @value = value
          @generated = generated
        end
      end

      attr_reader :explanation, :example, :method, :path
      attr_reader :request_body, :request_parameters, :request_headers
      attr_reader :response, :parsed_response, :response_parameters, :response_headers
      def initialize(explanation:, example:, method:, path:, request_parameters:, request_headers:, response:)
        @explanation    = explanation
        @example        = example
        @method         = method
        @path           = path
        @response       = response

        if request_parameters.is_a?(Hash)
          process_request_parameters(request_parameters)
        else
          @request_body = request_parameters
        end
        process_request_headers(request_headers || {})
        process_response_parameters
        process_response_headers
      end

      private

      def filter_values(name)
        values = instance_variable_get(:"@#{name}")
        return values if values.nil?

        included_values = DocumentRequests.configuration.send(:"include_#{name}")
        excluded_values = DocumentRequests.configuration.send(:"exclude_#{name}")
        hidden_values = DocumentRequests.configuration.send(:"hide_#{name}")
        enforce = DocumentRequests.configuration.send(:"enforce_explain_#{name}")

        unexplained = []
        values.select! do |k, v|
          next false if included_values and included_values.exclude?(k)
          next false if excluded_values.include?(k)
          unexplained << k if v.generated
          v.value = "..." if hidden_values.include?(k)
          true
        end
        raise "Unexplained parameters used: #{unexplained.join(", ")}" if enforce and unexplained.any?
        values
      end

      def process_request_parameters(parameters, prefix: nil)
        @request_parameters = {}
        process_parameters(parameters, @request_parameters, explanation: @explanation.request.parameters)
        filter_values :request_parameters
      end

      def process_request_headers(headers)
        @request_headers = {}
        headers.each do |name, value|
          @request_headers[name] = @explanation.request.headers[name] || Parameter.new(generated: true)
          @request_headers[name].value = value
        end
        @explanation.request.headers.each { |name, header| @request_headers[name] ||= header }
        filter_values :request_headers
      end

      def process_response_parameters(parameters = nil)
        @parsed_response = DocumentRequests.configuration.response_parser.call(response)
        if @parsed_response
          @response_parameters = {}
          process_parameters(@parsed_response, @response_parameters, explanation: @explanation.response.parameters)
        end
        filter_values :response_parameters
      end

      def process_response_headers
        @response_headers = {}
        @response.headers.each do |name, value|
          @response_headers[name] = @explanation.response.headers[name] || Parameter.new(generated: true)
          @response_headers[name].value = value
        end
        @explanation.response.headers.each { |name, header| @response_headers[name] ||= header }
        filter_values :response_headers
      end

      def process_parameters(input, output, explanation:, prefix: nil)
        input.each do |key, value|
          key, value = nil, key if input.is_a?(Array)
          if prefix
            name = "#{prefix}[#{key}]"
          else
            name = input.is_a?(Array) ? "[]" : key.to_s
          end
          case value
            when Hash
              process_parameters(value, output, explanation: explanation, prefix: name)
            when Array
              if value.all? { |subvalue| subvalue.is_a?(Hash) }
                process_parameters(value, output, explanation: explanation, prefix: name)
              else
                name += "[]"
                output[name] ||= explanation[name] || Parameter.new(generated: true)
                output[name].value = [output[name].value, value.to_s].compact.join(", ")
              end
            else
              output[name] ||= explanation[name] || Parameter.new(generated: true)
              output[name].value = [output[name].value, value].compact.join(", ")
          end
        end
        if prefix.nil?
          explanation.each { |name, parameter| output[name] ||= parameter }
        end
      end
    end
  end
end
