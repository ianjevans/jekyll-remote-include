require 'net/http'
require 'uri'

module Jekyll

  class RemoteInclude < Liquid::Tag

    def initialize(tag_name, remote_include, tokens)
      super
      @remote_include = remote_include
    end

    def open(url)
      Net::HTTP.get(URI.parse(url.strip)).force_encoding 'utf-8'
    end

    def render(context)
      # get the remote URL and see if the string has begin/end tokens
      input_split = split_params(@remote_include)
      url = input_split[0]
      if (input_split > 1)
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
          # if the file doesn't have the begin and end token just output the entire file
          output = raw
        end
      else
        output = open(url)
      end
      return output
    end

    def split_params(params)
      params.split("|")
    end
  end
end

Liquid::Template.register_tag('remote_include', Jekyll::RemoteInclude)
