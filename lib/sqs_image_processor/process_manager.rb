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
        pid = File.open("/tmp/sqs_image_processor_manager.pid", 'a+') {|f| f.read }.to_i
        Process.kill("KILL", pid)
        puts "Stopped instance of SqsImageProcessor."
      else
        puts "Error: SqsImageProcessor isn't running."
      end
    end

    def self.is_running?
      pid = File.open("/tmp/sqs_image_processor_manager.pid", 'a+') {|f| f.read }.to_i
      if pid == 0 || !self.pid_is_running?(pid)
        false
      else
        true
      end
    end

    def self.generate_pid_file
      File.open("/tmp/sqs_image_processor_manager.pid", 'w') {|f|
        f.write(Process.pid)
      }
    end

    def self.get_pid
      pid = File.open("/tmp/sqs_image_processor_manager.pid", 'a+') {|f| f.read }.to_i
    end
  end
end