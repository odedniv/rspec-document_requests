module RSpec
  module DocumentRequests
    module Writers
      autoload :Base,     'rspec/document_requests/writers/base'
      autoload :Markdown, 'rspec/document_requests/writers/markdown'
    end
  end
end
