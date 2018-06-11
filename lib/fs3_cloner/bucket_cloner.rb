require 'aws-sdk'

# BucketCloner
#
# Ex.
#
# Fs3Cloner::BucketCloner.new(
#   {
#     aws_access_key_id: '123',
#     aws_secret_access_key: '123',
#     bucket: 'bucket_from'
#   },
#   {
#     aws_access_key_id: '123',
#     aws_secret_access_key: '123',
#     bucket: 'bucket_to'
#   }
# ).clone
module Fs3Cloner
  class BucketCloner
    attr_reader :from_bucket, :to_bucket, :logger
    attr_reader :excludes, :includes, :output

    # options
    # - output        : STDOUT
    # - includes : ex. [%r(uploads/document), "uploads/1/document.pdf"]
    # - excludes : ex. [%r(uploads/1)]
    def initialize(from_credentials, to_credentials, options = {})
      parse_options(options)

      @from_bucket = bucket_from_credentials(from_credentials)
      @to_bucket   = bucket_from_credentials(to_credentials)
      @logger      = Logger.new(output)
    end

    def clone
      sync_count = 0
      skip_count = 0

      logger.info "Started syncing ..."

      from_bucket.objects.each do |object|
        if object_needs_syncing?(object)
          sync(object)
          sync_count += 1
        else
          skip(object)
          skip_count += 1
        end
      end

      logger.info "Done!"
      logger.info "Synced #{sync_count}"
      logger.info "Skipped #{sync_count}"
    end

    private

    def parse_options(options)
      @output   = options[:output] || STDOUT
      @excludes = options[:excludes]
      @includes = options[:includes]
    end

    def sync(object)
      logger.debug "Syncing #{pp object}"
      object.copy_to(to_bucket.object(object.key))
    end

    def skip(object)
      logger.debug "Skipped #{pp object}"
    end

    def pp(object)
      content_length_in_kb = object.content_length / 1024

      [
        %Q(#{object.key} #{content_length_in_kb}k),
        %Q(#{object.last_modified.strftime("%b %d %Y %H:%M")})
      ].join(' ')
    end

    def skip_object?(object)
      false ||
        object_include?(object) ||
        object_exclude?(object)
    end

    def object_needs_syncing?(object)
      to_object = to_bucket.object(object.key)

      return false if skip_object?(object)
      return true if !to_object.exists?
      return to_object.etag != object.etag
    end

    def bucket_from_credentials(credentials)
      client = Aws::S3::Client.new(access_key_id:      credentials[:aws_access_key_id],
                                   secret_access_key:  credentials[:aws_secret_access_key])

      bucket = Aws::S3::Bucket.new(credentials[:bucket], client: client)

      return bucket if bucket.exists?

      bucket.create
    end

    def object_include?(object)
      return true if includes.nil?

      includes.any? do |pattern|
        if pattern.is_a?(Regexp)
          match?(pattern, object.key)
        elsif pattern.is_a?(String)
          pattern == object.key
        else
          logger.error "Unknown include pattern, #{pattern}"
        end
      end
    end

    def object_exclude?(object)
      return false if excludes.nil?

      excludes.any? do |pattern|
        if pattern.is_a?(Regexp)
          match?(pattern, object.key)
        elsif pattern.is_a?(String)
          pattern == object.key
        else
          logger.error "Unknown include pattern, #{pattern}"
        end
      end
    end

    def match?(regex, string)
      !regex.match(string).nil?
    end
  end
end
