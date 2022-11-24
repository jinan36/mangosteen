require "rspec_api_documentation"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

RspecApiDocumentation.configure do |config|
  config.request_body_formatter = :json
  config.response_body_formatter =
    proc do |content_type, response_body|
      if /application\/.*json/.match?(content_type)
        JSON.pretty_generate(JSON.parse(response_body))
      else
        response_body
      end
    end
end
