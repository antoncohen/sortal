require 'kramdown'
require 'sanitize'

module Sortal
  module Email
    class Message
      attr_accessor :to
      attr_accessor :from_address
      attr_accessor :from_name
      attr_accessor :valid_from_domains
      attr_accessor :default_from
      attr_accessor :subject
      attr_accessor :body

      attr_reader :from
      attr_reader :reply_to
      attr_reader :body_html
      attr_reader :body_text

      def initialize( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        to = nil,
        from_address = nil,
        from_name = nil,
        valid_from_domains = nil,
        default_from = nil,
        subject = nil,
        body = nil
      )

        @to = to
        @from_address = from_address
        @from_name = from_name
        @valid_from_domains = valid_from_domains
        @subject = subject
        @default_from = default_from
        @body = body
      end

      # Builds a full message
      #
      # @return [Sortal::Email::Message] full message object
      def build
        from, reply_to = set_from(@from_address, @valid_from_domains, @default_from)
        @from = "#{@from_name} <#{from}>"
        @reply_to = reply_to ? "#{@from_name} <#{reply_to}>" : nil
        html = Kramdown::Document.new(@body, input: 'GFM').to_html
        @body_html = Sanitize.fragment(html, Sanitize::Config::RELAXED)
        @body_text = Sanitize.clean(@body)
        self
      end

      # Pick from and reply_to addresses
      #
      # To get around DMARC, if `from_address` is not in a valid domains,
      # set it to `default_from` and put `from_address` in `reply_to`.
      # @return [Array<String,nil>] from and reply_to addresses
      def set_from(requsted_from, valid_domains, default_from)
        requested_domain = requsted_from.split('@').last
        valid = valid_domains.include?(requested_domain)
        valid ? [requsted_from] : [default_from, requsted_from]
      end
    end
  end
end
