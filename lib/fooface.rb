# Pretty much verything you see here is copied from https://raw.github.com/appoxy/mini_fb

require "fooface/version"
require 'json' unless defined? JSON
require 'rest_client'
require 'logger'
require 'openssl'

module Fooface
  

    @@logging = true
    @@log = Logger.new(STDOUT)


    # Gets data from the Facebook Graph API
    # options:
    #   - type: eg: feed, home, etc
    #   - metadata: to include metadata in response. true/false
    #   - params: Any additional parameters you would like to submit

    def self.graph_base
      "https://graph.facebook.com/"
    end

    def self.get(access_token, id, options={})
      url = "#{graph_base}#{id}"
      url << "/#{options[:type]}" if options[:type]
      params = options[:params] || {}
      params["access_token"] = "#{(access_token)}"
      params["metadata"] = "1" if options[:metadata]
      params["fields"] = options[:fields].join(",") if options[:fields]
      options[:params] = params
      return fetch(url, options)
    end


    class FaceBookError < StandardError
      attr_accessor :code
      # Error that happens during a facebook call.
      def initialize(error_code, error_msg)
        @code = error_code
        super("Facebook error #{error_code}: #{error_msg}")
      end
    end

    def self.fetch(url, options={})
      begin
        if options[:method] == :post
          @@log.debug 'url_post=' + url if @@logging
          resp = RestClient.post url, options[:params]
        else
          if options[:params] && options[:params].size > 0
            url += '?' + options[:params].map { |k, v|  CGI.escape(k.to_s) + '=' + CGI.escape(v.to_s) }.join('&')
          end
          @@log.debug 'url_get=' + url if @@logging
          resp = RestClient.get url
        end

        @@log.debug 'resp=' + resp.to_s if @@log.debug?

        if options[:response_type] == :params
          # Some methods return a param like string, for example: access_token=11935261234123|rW9JMxbN65v_pFWQl5LmHHABC
          params = {}
          params_array = resp.split("&")
          params_array.each do |p|
            ps = p.split("=")
            params[ps[0]] = ps[1]
          end
          return params
        else
          begin
            res_hash = JSON.parse(resp.to_s)
          rescue
            # quick fix for things like stream.publish that don't return json
            res_hash = JSON.parse("{\"response\": #{resp.to_s}}")
          end
        end

        #if res_hash.is_a? Array # fql  return this
        #  res_hash.collect! { |x| x.is_a?(Hash) ? Hashie::Mash.new(x) : x }
        #else
        #  res_hash = Hashie::Mash.new(res_hash)
        #end

        if res_hash.include?("error_msg")
          raise FaceBookError.new(res_hash["error_code"] || 1, res_hash["error_msg"])
        end

        return res_hash
      rescue RestClient::Exception => ex
        puts "ex.http_code=" + ex.http_code.to_s
        puts 'ex.http_body=' + ex.http_body if @@logging
        res_hash = JSON.parse(ex.http_body) # probably should ensure it has a good response
        raise MiniFB::FaceBookError.new(ex.http_code, "#{res_hash["error"]["type"]}: #{res_hash["error"]["message"]}")
      end

    end

end
