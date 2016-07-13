require 'erb'
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'uri'

module Sortal
  module JIRA
    class Client
      def initialize(
        site = ENV['JIRA_SITE'],
        username = ENV['JIRA_USERNAME'],
        password = ENV['JIRA_PASSWORD'],
        base_path = ENV.fetch('JIRA_BASE_PATH', 'rest/api/2/')
      )

        jira_url = URI.join(site, base_path)
        @conn = Faraday.new(jira_url) do |faraday|
          faraday.request :json
          faraday.request :basic_auth, username, password
          faraday.headers['Accept'] = 'application/json'
          faraday.response :json, content_type: 'application/json'
          faraday.adapter Faraday.default_adapter
          faraday.use Faraday::Response::RaiseError
        end
      end

      def get(url)
        @conn.get(url).body
      end

      def post(url, data)
        @conn.post(url, data).body
      end
    end

    class User
      attr_accessor :username

      attr_reader :data

      def initialize(username = nil)
        @username = username
        @client = Sortal::JIRA::Client.new
      end

      # Get a data, set @data
      # @param username [String] must be a username, not an email address
      # @return [Hash] user data
      def get(username = @username)
        query_params = "?username=#{ERB::Util.url_encode(username)}"
        @data = @client.get('user' + query_params)
      rescue Faraday::Error::ResourceNotFound
        @data = nil
      end

      # Search for user by username or email address.
      # @param username [String] usernamd or email address
      # @return [Array<Hash>] matching users
      def search(username = @username)
        query_params = "?username=#{ERB::Util.url_encode(username)}"
        @client.get('user/search' + query_params)
      end

      # Get API user data
      #
      # JIRA supports logging in with an email address,
      # so ENV['JIRA_USERNAME'] could be an email address.
      #
      # JIRA only supports assigning an issue reporter by username.
      # This method is used to get the username of the API user.
      #
      # @return [Hash] user data
      def myself
        @data = @client.get('myself')
      end
    end

    class Issue
      attr_accessor :project
      attr_accessor :summary
      attr_accessor :description
      attr_accessor :issuetype
      attr_accessor :reporter

      attr_reader :data

      def initialize(
        project = ENV['JIRA_DEFAULT_PROJECT'],
        summary = nil,
        description = nil,
        issuetype = ENV.fetch('JIRA_DEFAULT_ISSUE_TYPE', 'Task'),
        reporter = nil
      )
        @project = project
        @summary = summary
        @description = description
        @issuetype = issuetype # TODO: Validate issue type
        @reporter = reporter
        @client = Sortal::JIRA::Client.new
      end

      # @return [Hash] api user data
      def api_user
        user = Sortal::JIRA::User.new
        user.myself
      end

      # Submits a new issue based on class attributes
      # @return [Hash] issue data
      def submit
        new_issue = {
          fields: {
            project: {
              key: @project
            },
            summary: @summary,
            description: @description,
            issuetype: {
              name: @issuetype
            },
            reporter: {
              name: @reporter || api_user['name']
            }
          }
        }

        @data = @client.post('issue/', new_issue)
      end
    end
  end
end
