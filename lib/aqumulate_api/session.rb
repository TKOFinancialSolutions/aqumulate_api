module AqumulateAPI

  class << self
    attr_accessor :session
  end

  def self.session
    @session ||= Session.new
  end

  def self.session=(session)
    @session = session
  end

  class Session

    attr_reader :config, :auth

    def initialize
      if block_given?
        @config = AqumulateAPI::Configuration.new
        yield(@config)
      else
        @config = AqumulateAPI.config
      end

      login
    end

    def login
      response = HTTParty.post(
          "#{config.url}/token",
          headers: { 'Accept' => 'application/x-www-form-urlencoded' },
          body: {
              grant_type: config.grant_type,
              'userName' => config.username,
              password: config.password
          }
      )

      @auth = handle_response response
    end

    def handle_response(response)
      if response.parsed_response.is_a?(Hash) && response.parsed_response.has_key?('error')
        raise AuthenticationError.new(response.parsed_response['error_description'], response.request)

      elsif response.code != 200
        raise RequestError.new(response.response.msg, response.response)

      elsif response.parsed_response.is_a?(Hash) && response.parsed_response.has_key?('Status') && response.parsed_response['Status'].to_i != 200
        raise RequestError.new(response.parsed_response['ErrorMessage'], response.parsed_response)
      end

      response.parsed_response
    end

    def api_request(resource, body)
      response = HTTParty.post(
          "#{config.url}/api/#{resource}",
          headers: {
              'Accept' => 'application/json',
              'Authorization' => "bearer #{auth['access_token']}"
          },
          body: body
      )

      handle_response response
    end

  end
end