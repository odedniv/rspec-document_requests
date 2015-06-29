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

        def title(description:, explanation:)
          @file.puts "# #{description}"
          @file.puts
          if explanation
            @file.puts explanation
            @file.puts
          end
        end

        def child(description:, filename:, last:)
          @file.puts "* [#{description}](#{filename})"
          @file.puts if last
        end

        def example_title(description:, explanation:, missing_levels:)
          @file.puts "## #{missing_levels.map { |l| "#{l[:description]} > " }.join}#{description}"
          @file.puts
          if explanation
            @file.puts explanation
            @file.puts
          end
        end

        module ParametersTable
          private

          def parameters_table(parameters)
            @file.puts "| Name | Type | Required? | Value |   |"
            @file.puts "|------|------|-----------|-------|---|"
            parameters.each do |name, parameter|
              @file.puts "| #{name}  | #{parameter.type}  | #{parameter.required || false}  | #{parameter.value}  | #{parameter.message}  |"
            end
            @file.puts
          end
        end

        class Request < Base::Request
          include ParametersTable

          def title(message)
            @file.puts "### Request#{" (#{message})" if message}"
            @file.puts
          end

          def path(method, path)
            @file.puts "    #{method} #{path}"
            @file.puts
          end

          def parameters(parameters)
            @file.puts "#### Parameters"
            @file.puts
            parameters_table(parameters)
          end

          def body(body)
            @file.puts "#### Body"
            @file.puts
            @file.puts "    #{body}"
            @file.puts
          end

          def headers(headers)
            @file.puts "#### Headers"
            @file.puts
            parameters_table(headers)
          end
        end

        class Response < Base::Response
          include ParametersTable

          def title(message)
            @file.puts "### Response#{" (#{message})" if message}"
            @file.puts
          end

          def status(status, message)
            @file.puts "#### Status"
            @file.puts
            @file.puts "    #{status} #{message}"
            @file.puts
          end

          def content_type(content_type)
            @file.puts "#### Content-Type"
            @file.puts
            @file.puts "    #{content_type}"
            @file.puts
          end

          def parameters(parameters)
            @file.puts "#### Parameters"
            @file.puts
            parameters_table(parameters)
          end

          def body(body)
            @file.puts "#### Body"
            @file.puts
            @file.puts "    #{body}"
            @file.puts
          end

          def headers(headers)
            @file.puts "#### Headers"
            @file.puts
            parameters_table(headers)
          end
        end
      end
    end
  end
end
