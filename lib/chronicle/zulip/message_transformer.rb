require 'chronicle/etl'

module Chronicle
  module Zulip
    class MessageTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.description = 'a zulip message'
        r.provider = 'zulip'
        r.identifier = 'message'
      end

      def transform
        build_messaged
      end

      def id
        message[:id]
      end

      def timestamp
        Time.at(message[:timestamp])
      end

      private 

      def message
        @message ||= @extraction.data
      end

      def participants
        @participants ||= begin
          message[:display_recipient].map do |recipient|
            build_user(
              id: recipient[:id],
              email: recipient[:email],
              full_name: recipient[:full_name],
              realm: message[:sender_realm_str]
            )
          end
        end
      end

      def build_messaged
        record = ::Chronicle::ETL::Models::Activity.new
        record.verb = 'messaged'
        record.provider = 'zulip'
        record.provider_id = id
        record.provider_namespace = message[:sender_realm_str]
        record.end_at = timestamp

        record.dedupe_on << [:verb, :provider, :provider_id]

        record.actor = build_actor
        record.involved = build_message
        record
      end

      def build_actor
        participants.find { |participant| participant.provider_id == message[:sender_id]}
      end

      def build_user(id:, email:, full_name:, realm:)
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'identity'
        record.provider = 'zulip'
        record.provider_id = id
        record.provider_namespace = realm
        record.title = full_name

        record.analogous = [ build_email_identity(email) ]

        record.dedupe_on << [:represents, :provider, :provider_id, :provider_namespace]

        record
      end

      def build_email_identity(email)
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'identity'
        record.provider = 'email'
        record.slug = email
        record.dedupe_on << [:represents, :provider, :slug]
        record
      end

      def build_message
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'message'
        record.provider = 'zulip'
        record.provider_id = id
        record.provider_namespace = message[:sender_realm_str]
        record.body = message[:content]

        record.consumers = participants.select { |participant| participant.provider_id != message[:sender_id] }

        record.dedupe_on << [:represents, :provider, :provider_id]

        record
      end
    end
  end
end
