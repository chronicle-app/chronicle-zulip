require 'faraday'

module Chronicle
  module Zulip
    class Proxy
      def initialize(username:, access_token:, realm:)
        @username = username
        @access_token = access_token 
        @realm = realm
      end

      def all_private_messages(anchor: 'oldest')
        narrow = '[{"negated":false,"operator":"is","operand":"private"}]'
        has_more = true

        while has_more
          response = load_messages(anchor: anchor, narrow: narrow)
          messages = response[:messages] || []

          messages.each do |message|
            yield message
          end

          has_more = !response[:found_newest]
          anchor = messages.map { |message| message[:id] }.max
        end
      end

      def load_messages(anchor:, narrow:)
        params = {
          narrow: narrow,
          num_after: '50',
          num_before: '0',
          anchor: anchor,
          apply_markdown: 'false'
        }

        make_request(endpoint: 'messages', params: params)
      end

      def make_request(endpoint:, params: {})
        conn = Faraday.new(
          url: zulip_subdomain,
          params: params
        ) do |conn|
          conn.use Faraday::Response::RaiseError
          conn.request :authorization, :basic, @username, @access_token
        end

        response = conn.get("api/v1/#{endpoint}")
        JSON.parse(response.body, { symbolize_names: true })
      end

      private

      def zulip_subdomain
        "https://#{@realm}.zulipchat.com"
      end
    end
  end
end
