# Fs3Cloner

Clone your s3 bucket either for backup or migration to a new bucket in new AWS account etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fs3_cloner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fs3_cloner

## Usage

```
Fs3Cloner::BucketCloner.new(
  {
    aws_access_key_id: '123',
    aws_secret_access_key: '123',
    bucket: 'bucket_from'
  },
  {
    aws_access_key_id: '123',
    aws_secret_access_key: '123',
    bucket: 'bucket_to'
  }
).run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fs3_cloner.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
