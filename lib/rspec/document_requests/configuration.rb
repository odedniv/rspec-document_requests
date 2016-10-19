module RSpec
  module DocumentRequests
    class Configuration
      def self.add_property(name, default = nil)
        attr_writer name
        define_method name do
          instance_variable_get(:"@#{name}") || default
        end
      end

      add_property :directory, ::Rails.root.join("doc")
      add_property :root, "Requests"
      add_property :group_levels, 1
      add_property :writer, Writers::Markdown
      add_property :filename_generator, -> (name) { name.downcase.gsub(/[_ ]+/, '-') }
      add_property :response_parser, -> (response) {
        case response.content_type
          when 'application/json' then JSON.parse(response.body)
        end
      }

      [:request, :response].each do |side|
        [:parameters, :headers].each do |part|
          add_property :"include_#{side}_#{part}", nil
          add_property :"exclude_#{side}_#{part}", []
          add_property :"hide_#{side}_#{part}", []
          add_property :"enforce_explain_#{side}_#{part}", false
        end
      end

      def directory=(directory)
        @directory = ::Rails.root.join(directory)
      end
    end
  end
end
