module RSpec
  module DocumentRequests
    class OrganizedRequest
      attr_reader :parent, :filename, :description, :example_requests, :children, :levels
      def initialize(description:, parent: nil)
        @description = description
        @parent = parent
        @filename = Pathname.new(DocumentRequests.configuration.filename_generator.call(description))
        @example_requests = Hash.new { |h, k| h[k] = [] }
        @children = {}
        @levels = Hash.new { |h, k| h[k] = 0 }
        @parent.increase_level(self) if @parent
      end

      def child(description)
        @children[DocumentRequests.configuration.filename_generator.call(description)] ||= OrganizedRequest.new(description: description, parent: self)
      end

      def increase_level(child)
        @grouped_children = @ungrouped_children = nil
        @levels[child] += 1
        @parent.increase_level(self) if @parent
      end

      def max_level
        @levels.values.max || 0
      end

      def grouped_children
        @grouped_children ||= @children.values.select { |child| child.max_level < DocumentRequests.configuration.group_levels }.sort_by(&:filename)
      end

      def ungrouped_children
        @ungrouped_children ||= (@children.values - grouped_children).sort_by(&:filename)
      end

      def self.organize
        root = OrganizedRequest.new(description: DocumentRequests.configuration.root)

        DSL.documented_requests.each do |request|
          current = request.example.example_group.metadata
          metadata_tree = [current]
          metadata_tree.unshift(current) while current = current[:parent_example_group]

          organized_request = root
          metadata_tree.each do |metadata|
            organized_request = organized_request.child(metadata[:description])
          end
          organized_request.example_requests[request.example] << request
        end

        root
      end
    end
  end
end
