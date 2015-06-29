module RSpec
  module DocumentRequests
    module DSL
      class << self
        attr_accessor :documented_requests
      end
      self.documented_requests = []

      [:get, :post, :patch, :put, :delete, :head].each do |method|
        define_method(method) do |path, parameters = nil, headers_or_env = nil|
          result = super(path, parameters, headers_or_env)

          if not @document_requests_prevented and @currently_documented_example
            DSL.documented_requests << Request.new(
              explanation:        document_request_explanation,
              example:            @currently_documented_example,
              method:             method.to_s.upcase,
              path:               path,
              request_parameters: parameters,
              request_headers:    headers,
              response:           response,
            )
          end
          @document_request_explanation = Explanation.new

          result
        end
      end

      def explain(&block)
        document_request_explanation.instance_eval(&block)
      end

      def document_request_explanation
        @document_request_explanation ||= Explanation.new
      end

      def nodoc
        was_prevented = @document_requests_prevented
        @document_requests_prevented = true
        if block_given?
          begin
            yield
          ensure
            @document_requests_prevented = false if not was_prevented
          end
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
    config.before(doc: true) { |ex| @currently_documented_example = ex }
    config.after(doc: true) { |ex| @currently_documented_example = nil }
  end

  config.include RSpec::DocumentRequests::DSL, doc: true
end
