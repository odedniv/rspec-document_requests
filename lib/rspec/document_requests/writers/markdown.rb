module RSpec
  module DocumentRequests
    module Writers
      class Markdown < Base
        EXTENSION = ".md"

        def breadcrumb(description:, filename:, last:)
          @file.write "[#{description}](#{filename})"
          if not last
            @file.write " > "
          else
            @file.puts
            @file.puts
          end
        end

        def title(description)
          @file.puts "# #{description}"
          @file.puts
        end

        def child(description:, filename:)
          @file.puts "* [#{description}](#{filename})"
        end

        def example_title(description, missing_levels:)
          @file.puts "## #{missing_levels.map { |l| "#{l} > " }.join} #{description}"
          @file.puts
        end

        def request(request, missing_levels:)
          @file.write <<FILE
### Request#{" (#{request.explanation.message})" if request.explanation.message}

    #{request.method} #{request.path}

FILE

          if request.request_parameters.any?
            @file.write <<FILE
#### Parameters

FILE
            parameters_table(request.request_parameters)
          end

          if request.request_headers.any?
            @file.write <<FILE
#### Headers

FILE
            parameters_table(request.request_headers)
          end

          @file.write <<FILE
### Response

#### Status

    #{request.response.status} #{request.response.status_message}

#### Content-Type

    #{request.response.content_type}

FILE

          if request.response_parameters and request.response_parameters.any?
            @file.write <<FILE
#### Parameters

FILE
            parameters_table(request.response_parameters)
          end

          @file.write <<FILE
#### Body

    #{request.response.body}

FILE

          if request.response_headers.any?
            @file.write <<FILE
#### Headers

FILE
            parameters_table(request.response_headers)
          end
        end

        private

        def parameters_table(parameters)
          @file.write <<FILE
| Name | Type | Required? | Value |   |
|------|------|-----------|-------|---|
FILE

          parameters.sort.each do |name, parameter|
            @file.puts "| #{name}  | #{parameter.type}  | #{"Required" if parameter.required}  | #{parameter.value}  | #{parameter.message}  |"
          end
          @file.puts
        end
      end
    end
  end
end
