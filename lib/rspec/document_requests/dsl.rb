module RSpec
  module DocumentRequests
    module DSL
      class << self
        attr_accessor :documented_requests, :currently_documented_example
      end
      self.documented_requests = []
      self.currently_documented_example = nil

      [:get, :post, :patch, :put, :delete, :head].each do |method|
        define_method(method) do |path, parameters = nil, headers_or_env = nil|
          result = super(path, parameters, headers_or_env)

          if not @document_request_prevented and DSL.currently_documented_example
            DSL.documented_requests << Request.new(
              explanation:        document_request_explanation,
              example:            DSL.currently_documented_example,
              method:             method.to_s.upcase,
              path:               path,
              request_parameters: parameters,
              request_headers:    headers,
              response:           response,
            )
          end
          @document_request_explanation = Explanation.new
          DSL.currently_documented_example = nil

          result
        end
      end

      def explain(message = nil, &block)
        document_request_explanation.message = message
        document_request_explanation.instance_eval(&block) if block_given?
      end

      def document_request_explanation
        @document_request_explanation ||= Explanation.new
      end

      def nodoc
        @document_request_prevented = true
        begin
          yield
        ensure
          @document_request_prevented = false
        end
      end
    end
  end
end

RSpec.configure do |config|
  if ENV['DOC']
    config.filter_run :doc
    config.run_all_when_everything_filtered = false

    config.after(:suite) { RSpec::DocumentRequests::Builder.new }
    config.before { |ex| RSpec::DocumentRequests::DSL.currently_documented_example = ex }
  end

  config.include RSpec::DocumentRequests::DSL, doc: true
end
