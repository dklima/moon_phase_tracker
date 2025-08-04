# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module MoonPhaseTracker
  class Client
    BASE_URL = "https://aa.usno.navy.mil/api/moon/phases"
    TIMEOUT = 10

    def initialize
      @uri_cache = {}
    end

    def phases_from_date(date, num_phases = 12)
      validate_date_format!(date)
      validate_num_phases!(num_phases)
      
      params = { date: date, nump: num_phases }
      make_request("#{BASE_URL}/date", params)
    end

    def phases_for_year(year)
      validate_year!(year)
      
      params = { year: year }
      make_request("#{BASE_URL}/year", params)
    end

    private

    def make_request(endpoint, params = {})
      uri = build_uri(endpoint, params)
      
      begin
        response = fetch_with_timeout(uri)
        parse_response(response)
      rescue Net::TimeoutError, Net::OpenTimeout, Net::ReadTimeout => e
        raise NetworkError, "Request timeout: #{e.message}"
      rescue Net::HTTPError, SocketError => e
        raise NetworkError, "Network error: #{e.message}"
      rescue JSON::ParserError => e
        raise APIError, "Invalid JSON response: #{e.message}"
      end
    end

    def build_uri(endpoint, params)
      cache_key = "#{endpoint}_#{params.hash}"
      
      @uri_cache[cache_key] ||= begin
        uri = URI(endpoint)
        uri.query = URI.encode_www_form(params) unless params.empty?
        uri
      end
    end

    def fetch_with_timeout(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", 
                      open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "MoonPhaseTracker/#{MoonPhaseTracker::VERSION}"
        
        response = http.request(request)
        
        unless response.is_a?(Net::HTTPSuccess)
          raise APIError, "API request failed: #{response.code} - #{response.message}"
        end
        
        response
      end
    end

    def parse_response(response)
      data = JSON.parse(response.body)
      
      if data["error"]
        raise APIError, "API error: #{data["error"]}"
      end

      data
    end

    def validate_date_format!(date)
      return if date.match?(/^\d{4}-\d{1,2}-\d{1,2}$/)
      
      raise InvalidDateError, "Date must be in YYYY-MM-DD format"
    end

    def validate_num_phases!(num_phases)
      unless num_phases.is_a?(Integer) && num_phases.between?(1, 99)
        raise InvalidDateError, "Number of phases must be between 1 and 99"
      end
    end

    def validate_year!(year)
      current_year = Date.today.year
      
      unless year.is_a?(Integer) && year.between?(1700, current_year + 10)
        raise InvalidDateError, "Year must be between 1700 and #{current_year + 10}"
      end
    end
  end
end