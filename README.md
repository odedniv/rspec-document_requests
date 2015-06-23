# RSpec::DocumentRequests [![Gem Version](https://badge.fury.io/rb/rspec-document_requests.svg)](http://badge.fury.io/rb/rspec-document_requests)

This gem is an extension to [rspec-rails](https://github.com/rspec/rspec-rails),
which adds the capability to automatically document requests made by your
request specs. This will help you document your API effortlessly.

This was made after checking out
[rspec_api_documentation](https://github.com/zipmark/rspec_api_documentation),
in which I didn't like the fact that it forces you into its own DSL (which is
basically a small subset of RSpec DSL). If you liked it, you'll probably like
this one more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-document_requests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-document_requests

## Usage

### Require

Require the DSL _after_ you require `rspec/rails` (most likely in your
`spec/rails_helper.rb`):

```ruby
# spec/rails_helper.rb

...
require 'rspec/rails'
require 'rspec/document_requests/dsl' # <- this line
...
```

### Marking code to document

In your example group (`describe`/`context`), simply add the `doc: true` metadata:

```ruby
# spec/requests/session_spec.rb

RSpec.describe "Session resource", type: :request, doc: true do
  describe "Create session" do
    # User creation, will not be documented in "Session resource" documentation (nodoc)
    before do
      nodoc { post "/users", user: { username: "myuser", password: "123123" } }
    end

    context "Correct password" do
      before { post "/session", session: { username: "myuser", password: "123123" } }
      it { ... }
    end

    context "Incorrect password" do
      before { post "/session", session: { username: "myuser", password: "456456" } }
      it { ... }
    end

    # Extra test, will not be documented (doc: false)
    context "Incorrect username", doc: false do
      before { post "/session", session: { username: "wronguser", password: "123123" } }
      it { ... }
    end
  end
end
```

### Running in documentation mode

To prevent every rspec run deleting all your documentation, this gem only
documents the requests when `DOC=true` environment variable is set. This will
also exclude any specs without `doc: true` metadata to make this run faster.

    DOC=true rake spec

### Explaining the request

**NOTE:** This DSL is not available in `doc: false` example groups (`describe`/`context`).

Just before your request, it's a good idea to explain (everything is optional):

```ruby
# spec/requests/session_spec.rb

RSpec.describe "Session resource", type: :request, doc: true do
  describe "Create session" do
    before do
      explain "Creating the user"
      post "/users", user: { username: "myuser", password: "123123" }
    end

    before do
      explain do # No request explanation
        request do
          parameter 'session[username]', "The username", required: true, type: :string
          parameter 'session[password]', required: true, type: :string # No explanation
          header 'Content-Type', ... # you get the point
        end
        response do
          parameter 'message', "Message from the server", required: true # No type
          parameter 'session_id', "The session ID" # Not required and no type
          header 'Set-Cookie', ...
        end
      end
      post "/session", session: { username: "myuser", password: "123123" }
    end
    it { ... }
  end
end
```

**NOTE:** Explaining response parameters only works when this gem can
parse the response body, see [here](#configuration) how to configure it.

### Configuration

These are the possible configurations:

```ruby
# spec/document_requests_helper.rb

RSpec::DocumentRequests.configure do |config|
  # These are the default values

  config.directory = "doc" # From Rails.root. CAREFUL: directory/root gets deleted!
  config.root = "Requests" # I actually use API, figured this is a better default
  # Example groups with less than this amount of example group (describe/context)
  # levels under it will be grouped under its parent example group.
  config.group_levels = 1
  # Currently only markdown available with the gem.
  # Contribute more by checking out lib/rspec/document_requests/writers/base.rb.
  config.writer = RSpec::DocumentRequests:::Writers::Markdown
  # Converts example groups (describe/context) to filenames (and directories), the default simple
  # lower-cases and uses dash (-) for spaces.
  config.filename_generator = -> (name) { name.downcase.gsub(/[_ ]+/, '-') }
  # Allows showing response body as a table of parameters (with explanations).
  # Don't forget to contribute more!
  config.response_parser = -> (response) {
    case
      when response.content_type.json? then JSON.parse(response.body)
    end
  }

  config.include_request_parameters  = nil # nil means not used
  config.exclude_request_parameters  = []
  config.hide_request_parameters     = [] # Displays '...' instead of actual value
  config.include_response_parameters = nil
  config.exclude_response_parameters = []
  config.hide_response_parameters    = []
end
```

Don't forget to require your file:

```ruby
# .rspec

--require document_requests_helper

```

## REQUIRED best practices

It's always a good idea to follow this best-practice, but for this gem to work
it's necessary.

The implementation documents example groups (`describe`/`context`), and not
examples (`it`/`specify`).

It is important that you do not make requests
(`get`/`post`/`put`/`patch`/`delete`/`head`) from inside an example
(`it`/`specify`). It will only document requests from the first example of each
example group (`describe`/`context`).

It does however work only from inside examples (`it`/`specify`)
so requests from any form of `before`/`after`/`around` that is _not_ `:each`
will not be documented.

This best practice has other upsides other than making this gem work which I
will not describe here. But here is a nice example for this best practice to follow:

```ruby
RSpec.describe "Some interface (class/feature/API resource)", doc: true do
  subject { response }

  describe "An interface within the interface (method/action/sub-feature)" do
    before { post "/api/action", param: param_value }

    context "Some scenario (attributes/params/prerequisite)" do
      let(:param_value) { "scenario value" }

      it { should have_http_status :ok }
      # "body is not wrong" will not be documented
      specify("body is not wrong") { expect(response.body).to eq "something" }
    end

    context "Another scenario" do
      let(:param_value) { "another scenario" }

      ...
    end
  end

  context "Some scenario" do
    before { nodoc { post "/api/scenario_prerequisite" } }

    describe "An interface" do
      before { get "/api/result" }

      ...
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

The gem works, but it's missing some basics:

* Unit tests (specs).
* Example generated documentations.
* More writers (see `lib/rspec/document_requests/writers/base.rb`).

So...

1. Fork it ( https://github.com/odedniv/rspec-document_requests/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
