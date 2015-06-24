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
          @current.ungrouped_children.each { |child| write_child(child, last: child == @current.ungrouped_children.last) }
          write_recursive_requests(@current)
          @writer.close
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
          missing_levels.unshift(missing) while (missing = missing.parent) and missing != @current
        end
        missing_levels = missing_levels.map do |organized_entry|
          {
            description: organized_entry.metadata[:description],
            explanation: metadata_explanation(organized_entry.metadata),
          }
        end

        child.example_requests.to_a.uniq { |e,| e.example_group }.each do |example, requests|
          write_example_title(example, missing_levels: missing_levels) unless child == @current
          requests.each { |request| write_request(request) }
        end

        child.grouped_children.each_with_index do |grandchild, i|
          write_recursive_requests(grandchild)
        end
      end

      def metadata_explanation(metadata)
        metadata[:explanation] if metadata[:parent_example_group].nil? or metadata[:explanation] != metadata[:parent_example_group][:explanation]
      end

      def write_breadcrumb
        current = @current
        parent_tree = []
        parent_tree.unshift(current) while current = current.parent

        return if parent_tree.empty?

        parent_path = Pathname.new('.').join(*parent_tree.length.times.map { '..' })
        parent_tree.each do |parent|
          @writer.breadcrumb(
            description: parent.metadata[:description],
            filename:    parent_path.join(parent.filename).sub_ext(config.writer::EXTENSION),
            last:        parent == @current.parent,
          )
          parent_path = parent_path.split[0]
        end
      end

      def write_title
        metadata = @current.metadata
        @writer.title(description: metadata[:description], explanation: metadata_explanation(metadata))
      end

      def write_child(child, last:)
        @writer.child(
          description: child.metadata[:description],
          filename:    @current.filename.join(child.filename).sub_ext(config.writer::EXTENSION),
          last:        last,
        )
      end

      def write_example_title(example, missing_levels:)
        metadata = example.example_group.metadata
        @writer.example_title(description: metadata[:description], explanation: metadata_explanation(metadata), missing_levels: missing_levels)
      end

      def write_request(request)
        # request
        @writer.request.title(request.explanation.request.message)
        @writer.request.path(request.method, request.path)
        @writer.request.parameters(request.request_parameters) if request.request_parameters.present?
        @writer.request.body(request.request_body)             if request.request_body.present?
        @writer.request.headers(request.request_headers)       if request.request_headers.present?
        # response
        @writer.response.title(request.explanation.response.message)
        @writer.response.status(request.response.status, request.response.status_message)
        @writer.response.content_type(request.response.content_type)
        @writer.response.parameters(request.response_parameters) if request.response_parameters.present?
        @writer.response.body(request.response.body)             if request.response.body.present?
        @writer.response.headers(request.response_headers)       if request.response_headers.present?
      end
    end
  end
end
