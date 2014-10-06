require 'fileutils'

module SqsImageProcessor
  module ProcessManager
    def self.pid_is_running?( pid )
      begin
        Process.getpgid( pid.to_i )
        true
      rescue Errno::ESRCH
        false
      end
    end

    def self.kill
      if self.is_running?
        pid = File.open("/tmp/sqs_image_processor.pid", 'a+') {|f| f.read }.to_i
        Process.kill("KILL", pid)
        Dir.foreach('/tmp/sqs_image_processor') do |item|
          next if item == '.' or item == '..'
          begin
            Process.kill("KILL", item.gsub('.pid','').to_i)
          rescue
          end
        end
        puts "Stopped instance of SqsImageProcessor."
      else
        puts "Error: SqsImageProcessor isn't running."
      end
    end

    def self.is_running?
      pid = File.open("/tmp/sqs_image_processor.pid", 'a+') {|f| f.read }.to_i
      if pid == 0 || !self.pid_is_running?(pid)
        false
      else
        true
      end
    end

    def self.generate_pid_file
      FileUtils.mkdir_p '/tmp/sqs_image_processor'
      File.open("/tmp/sqs_image_processor.pid", 'w') {|f|
        f.write(Process.pid)
      }
    end

    def self.generate_child_pid_file( pid )
      File.open("/tmp/sqs_image_processor/#{pid}.pid", 'w') {|f|
        f.write(pid)
      }
    end

    def self.get_pid
      pid = File.open("/tmp/sqs_image_processor.pid", 'a+') {|f| f.read }.to_i
    end
  end
end