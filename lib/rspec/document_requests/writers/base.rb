module RSpec
  module DocumentRequests
    module Writers
      class Base
        #EXTENSION = ".something"

        attr_reader :request, :response

        def initialize(file)
          @file = file
          @request = self.class::Request.new(file)
          @response = self.class::Response.new(file)
        end

        def breadcrumb(description:, filename:, last:)
          raise NotImplementedError
        end

        def title(description:, explanation:)
          raise NotImplementedError
        end

        def child(description:, filename:, last:)
          raise NotImplementedError
        end

        # missing_levels: [{ description: "", explanation: "" || nil }, ...]
        def example_title(description:, explanation:, missing_levels:)
          raise NotImplementedError
        end

        def close
          @request.close
          @response.close
        end

        class Request
          def initialize(file)
            @file = file
          end

          def title(message)
            raise NotImplementedError
          end

          def path(method, path)
            raise NotImplementedError
          end

          def parameters(parameters)
            raise NotImplementedError
          end

          def body(body)
            raise NotImplementedError
          end

          def headers(headers)
            raise NotImplementedError
          end

          def close
          end
        end

        class Response
          def initialize(file)
            @file = file
          end

          def title(message)
            raise NotImplementedError
          end

          def status(status, message)
            raise NotImplementedError
          end

          def content_type(content_type)
            raise NotImplementedError
          end

          def parameters(parameters)
            raise NotImplementedError
          end

          def body(body)
            raise NotImplementedError
          end

          def headers(headers)
            raise NotImplementedError
          end

          def close
          end
        end
      end
    end
  end
end
