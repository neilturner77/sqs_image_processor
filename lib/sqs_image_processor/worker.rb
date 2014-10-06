require 'aws-sdk-core'
require 'uri'

module SqsImageProcessor
  module Worker
    def self.start( config )
      SqsImageProcessor::ProcessManager.generate_child_pid_file(Process.pid)
      continue_processing = true
      
      sqs_client = Aws::SQS::Client.new(
        credentials: Aws::Credentials.new(config.aws.sqs.access_key_id, config.aws.sqs.secret_access_key),
        region: config.aws.sqs.region
      )
      s3_client = Aws::S3::Client.new(
        credentials: Aws::Credentials.new(config.aws.s3.access_key_id, config.aws.s3.secret_access_key),
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
              filename = File.basename(resp.messages[0].body)
              version_filename = "#{filename.chomp(File.extname(filename))}_#{version_name}#{File.extname(filename)}"
              version_path = "#{resp.messages[0].body.chomp(filename)}#{version_filename}}"
              system("gm convert /tmp/#{filename} -resize '#{width}x#{height}' +profile \"*\" /tmp/#{version_filename} > /dev/null")

              # Upload to S3
              s3_resp = s3_client.put_object(
                acl: "public-read",
                body: File.open("/tmp/#{version_filename}"),
                bucket: config.aws.s3.bucket,
                key: version_path
              )

              File.delete("/tmp/#{version_filename}") if File.exists?("/tmp/#{version_filename}")

            end
            sqs_client.delete_message(
              queue_url: queue.queue_url,
              receipt_handle: resp.messages[0].receipt_handle
            )
            File.delete("/tmp/#{File.basename(resp.messages[0].body)}") if File.exists?("/tmp/#{File.basename(resp.messages[0].body)}")
          end
        rescue
          # Immediately return this item to the queue for processing.
          begin
            if resp && resp.messages != nil
              sqs_client.change_message_visibility(
                queue_url: queue.queue_url,
                receipt_handle: resp.messages[0].receipt_handle,
                visibility_timeout: 0
              )
            end
          rescue
            # Just continue anyway
          end
        end
        sleep 0.1
      end
    end
  end
end