# jekyll-remote-include

A Liquid tag plugin for Jekyll that allows remote includes from external sources.

## Installation

Add this line to your application's Gemfile:
```ruby
group :jekyll_plugins do
    gem 'jekyll-remote-include', "~> 1.1.3", github: 'ianjevans/jekyll-remote-include'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-remote-include

Then add the following to your site's `_config.yml`:

```yaml
plugins:
  - jekyll-remote-include
```

💡 If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

## Usage

The tag can be used to include the entire contents of a file, or just the content between begin and end tokens, in your Jekyll pages, posts and collections.

To include the entire file:

```liquid
{% remote_include https://raw.githubusercontent.com/jekyll/jekyll/master/README.markdown %}
```

To include only a portion of the file, specify the begin and end tokens separated by the pipe (|) character:

```liquid
{% remote_include https://raw.githubusercontent.com/jekyll/jekyll/master/README.markdown|begin_token|end_token %}
```

If the linked file doesn't contain the begin or end tokens, the entire file will be included.

## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
