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
        end
      end

      def get(url)
        @conn.get(url).body
      end

      def post(url, data)
        @conn.post(url, data).body
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

      # Search for user by username or email address.
      # Used to get the JIRA username when we only have the email address.
      # Returns an array of user hashes.
      def search_username(username)
        query_params = "?username=#{ERB::Util.url_encode(username)}"
        @client.get('user/search' + query_params)
      end

      # Get the user hash of the API user.
      # JIRA supports logging in with an email address,
      # so ENV['JIRA_USERNAME'] could be an email address.
      # JIRA only supports assigning an issue reporter by username.
      # This method is used to get the username of the API user.
      # Returns user hash.
      def api_user
        @client.get('myself')
      end

      # Determines who the issue reporter should be.
      # If username is set, and a search only find a single user with that
      # that name, return that username, otherwise return the API user's
      # username.
      def real_reporter(username = nil)
        if username
          users = search_username(username)
          users.length == 1 ? users[0]['name'] : api_user['name']
        else
          api_user['name']
        end
      end

      # Submits a new issue based on class attributes.
      # Returns hash of issue data, including new issue key.
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
              name: real_reporter(@reporter)
            }
          }
        }

        @data = @client.post('issue/', new_issue)
      end
    end
  end
end
