require 'aws-sdk-core'
require 'uri'

module SqsImageProcessor
  module Worker
    def self.start( config )
      continue_processing = true
      
      sqs_client = Aws::SQS::Client.new(
        credentials: Aws::Credentials.new(config.aws.sqs.access_key_id, config.aws.sqs.secret_access_key),
        region: config.aws.sqs.region
      )
      queue = sqs_client.get_queue_url({queue_name: config.aws.sqs.queue_name})
      
      while continue_processing
        begin
          resp = sqs_client.receive_message( {queue_url: queue.queue_url} )
          if resp.messages != nil
            url = "http://#{config.aws.s3.bucket}.s3.amazonaws.com/#{resp.messages[0].body}"
            puts "Converting #{url}"
            system("wget -O /tmp/#{File.basename(resp.messages[0].body)} #{url} --no-cache > /dev/null")
            config.versions.to_h.each do |k, v|
              version_name = k
              width = v['width']
              height = v['height']
              system("gm convert /tmp/#{File.basename(resp.messages[0].body)} -resize '#{width}x#{height}>' +profile \"*\" /tmp/#{version_name}_#{File.basename(resp.messages[0].body)} > /dev/null")
            end
            sqs_client.delete_message(
              queue_url: queue.queue_url,
              receipt_handle: resp.messages[0].receipt_handle
            )
          end
        rescue
          # Immediately return this item to the queue for processing.
          if resp && resp.messages != nil
            sqs_client.change_message_visibility(
              queue_url: queue.queue_url,
              receipt_handle: resp.messages[0].receipt_handle,
              visibility_timeout: 0
            )
          end
        end
        sleep 0.1
      end
    end
  end
end