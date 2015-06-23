module RSpec
  module DocumentRequests
    class Builder
      def initialize
        clean
        @root = OrganizedRequest.organize
        write
      end

      private

      def config
        DocumentRequests.configuration
      end

      def clean
        root_directory = config.directory.join(config.filename_generator.call(config.root))
        root_filename = root_directory.sub_ext(config.writer::EXTENSION)

        root_directory.rmtree if root_directory.exist?
        root_filename.delete if root_filename.exist?
      end

      def write(organized_request = @root, fullpath: config.directory)
        @current = organized_request
        @current_path = fullpath

        @current_path.mkpath
        @current_path.join(@current.filename).sub_ext(config.writer::EXTENSION).open('wb') do |file|
          @writer = config.writer.new(file)
          write_breadcrumb
          write_title
          @current.ungrouped_children.each { |child| write_child(child) }
          write_recursive_requests(@current)
        end

        @current.ungrouped_children.each do |child|
          # @current unusable from here on-end
          write(child, fullpath: fullpath.join(organized_request.filename))
        end
      end

      def write_recursive_requests(child)
        missing_levels = []
        if not child == @current
          missing = child
          missing_levels.unshift(missing.description) while (missing = missing.parent) and missing != @current
        end

        child.example_requests.to_a.uniq { |e,| e.example_group }.each do |example, requests|
          write_example_title(example, missing_levels: missing_levels) unless child == @current
          requests.each { |request| write_request(request, missing_levels: missing_levels) }
        end

        child.grouped_children.each_with_index do |grandchild, i|
          write_recursive_requests(grandchild)
        end
      end

      def write_breadcrumb
        current = @current
        parent_tree = []
        parent_tree.unshift(current) while current = current.parent

        return if parent_tree.empty?

        parent_path = Pathname.new('.').join(*parent_tree.length.times.map { '..' })
        parent_tree.each do |parent|
          @writer.breadcrumb(
            description: parent.description,
            filename:    parent_path.join(parent.filename).sub_ext(config.writer::EXTENSION),
            last:        parent == @current.parent,
          )
          parent_path = parent_path.split[0]
        end
      end

      def write_title
        @writer.title(@current.description)
      end

      def write_child(child)
        @writer.child(
          description: child.description,
          filename:    @current.filename.join(child.filename).sub_ext(config.writer::EXTENSION),
        )
      end

      def write_example_title(example, missing_levels:)
        @writer.example_title(example.example_group.metadata[:description], missing_levels: missing_levels)
      end

      def write_request(request, missing_levels:)
        @writer.request(request, missing_levels: missing_levels)
      end
    end
  end
end
