module RSpec
  module DocumentRequests
    module Writers
      class Base
        #EXTENSION = ".something"

        def initialize(file)
          @file = file
        end

        def breadcrumb(description:, filename:, last:)
          raise NotImplementedError
        end

        def title(description)
          raise NotImplementedError
        end

        def child(description:, filename:)
          raise NotImplementedError
        end

        def request_title(description, missing_levels:)
          raise NotImplementedError
        end

        def request(request, missing_levels:)
          raise NotImplementedError
        end
      end
    end
  end
end
