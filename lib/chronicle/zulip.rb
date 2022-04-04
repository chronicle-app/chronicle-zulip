# frozen_string_literal: true

require_relative "zulip/version"
require_relative "zulip/proxy"
require_relative "zulip/private_message_extractor"
require_relative "zulip/message_transformer"

module Chronicle
  module Zulip
    class Error < StandardError; end
    # Your code goes here...
  end
end
