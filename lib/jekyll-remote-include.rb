require 'net/http'
require 'uri'
require 'logger'

module Jekyll

  class RemoteInclude < Liquid::Tag

    def cache
      @@cache ||= Jekyll::Cache.new("RemoteInclude")
    end

    def initialize(tag_name, remote_include, tokens)
      super
      @remote_include = remote_include
    end

    # Returns the plugin's config or an empty hash if not set
    def config
      @config ||= @context.registers[:site].config['remote_include'] || {}
    end

    def open(url)
      if config['use_cache'] == true || !config.has_key?('use_cache')
        cache.getset(url) do
          Net::HTTP.get(URI.parse(url.strip)).force_encoding 'utf-8'
        end
      elsif !config["use_cache"]
        Net::HTTP.get(URI.parse(url.strip)).force_encoding 'utf-8'
      else
        @logger.warn("use_cache set to non-boolean value, retrieving remote file just in case.")
        Net::HTTP.get(URI.parse(url.strip)).force_encoding 'utf-8'
      end
    end

    def render(context)
      @context = context
      @logger = Logger.new(STDOUT)
      # get the remote URL and see if the string has begin/end tokens
      input_split = split_params(@remote_include)
      url = input_split[0]
      if input_split.length() > 1
        # first parameter is the begin token string
        begin_token = input_split[1]
        # second parameter is the end token string
        end_token = input_split[2]
        raw = open(url)
        # make sure the begin/end tokens are present in the remote file
        if raw.match?(begin_token) && raw.match?(end_token)
          # get the lines between the tokens
          output = raw.match(/#{begin_token}(.*)#{end_token}/m)[1]
        else
          begin_match = raw.match?(begin_token) ? "True" : "False"
          end_match = raw.match?(end_token) ? "True" : "False"
          @logger.warn("Remote file fragment doesn't contain begin and end token.")
          @logger.warn("Page: " << context.environments.first["page"]["path"])
          @logger.warn("Url: " << url)
          @logger.warn("Begin token: " << begin_token)
          @logger.warn("Begin token present? " << begin_match)
          @logger.warn("End token: " << end_token)
          @logger.warn("End token present? " << end_match)
          if config["on_token_error"] == "fail" || !config.has_key?("on_token_error")
            # Fail the build by default if there are token errors
            raise ArgumentError, "Remote fragment include error in " << context.environments.first["page"]["path"]
          elsif config["on_token_error"] == "full"
            # if the file doesn't have the begin and end token just output the entire file
            output = raw
          elsif config["on_token_error"] == "none"
            output = ""
          else
            raise ArgumentError, "on_token_error setting in remote_include configuration invalid"
          end
        end
      else
        output = open(url)
      end
      return output
    end

    def split_params(params)
      params.split("|").map(&:strip)
    end
  end
end

Liquid::Template.register_tag('remote_include', Jekyll::RemoteInclude)
