require 'rspec/document_requests/version'

module RSpec
  module DocumentRequests
    autoload :Configuration,    'rspec/document_requests/configuration'
    autoload :Request,          'rspec/document_requests/request'
    autoload :Explanation,      'rspec/document_requests/explanation'
    autoload :DSL,              'rspec/document_requests/dsl'
    autoload :OrganizedRequest, 'rspec/document_requests/organized_request'
    autoload :Builder,          'rspec/document_requests/builder'
    autoload :Writers,          'rspec/document_requests/writers'

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield self.configuration
    end
  end
end
