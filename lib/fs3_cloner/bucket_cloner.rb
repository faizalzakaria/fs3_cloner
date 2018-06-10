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
# ).run
module Fs3Cloner
  class BucketCloner
    attr_reader :from_bucket, :to_bucket, :logger

    def initialize(from_credentials, to_credentials, output: STDOUT)
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

    def object_needs_syncing?(object)
      to_object = to_bucket.object(object.key)

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
  end
end
