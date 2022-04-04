require 'chronicle/etl'
require 'faraday'
module Chronicle
  module Zulip
    class PrivateMessageExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'zulip'
        r.description = 'zulip direct messages'
        r.identifier = 'private-message'
      end

      setting :access_token, required: true
      setting :username, required: true
      setting :realm, required: true

      def prepare
        @proxy = Chronicle::Zulip::Proxy.new(username: @config.username, realm: @config.realm, access_token: @config.access_token)
      end

      def extract
        @proxy.all_private_messages(since: @config.since, limit: @config.limit) do |message|
          yield Chronicle::ETL::Extraction.new(data: message)
        end
      end
    end
  end
end
