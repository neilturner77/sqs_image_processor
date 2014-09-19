require "thor"

# :stopdoc:
# SQS Image Processor offers a minimalist interface to make using it
# as easy as we can. The command line interface is implemented using
# Thor but this could easily be standard ruby if we want to strip out
# dependencies and streamline the gem.
# :startdoc:
module SqsImageProcessor 

  # Main interface to the application. Provides 4 commands to the user.
  #
  # - start
  # - stop
  # - status
  # - generate_config
  class Manager < Thor

    desc "start", "Start the SQS Image Processor."
    method_option :c, :type => :string, :default => File.join(Dir.pwd, 'sqs_image_processor_config.yml'), :required => false
    method_option :d, :type => :boolean, :default => false, :required => false
    def start
      config_path = options[:c]
      daemonize = options[:d]

      if !File.exists?(config_path)
        puts "Error: Config file not found."
      elsif SqsImageProcessor::ProcessManager.is_running?
        puts "Error: An instance of SqsImageProcessor is already running."
      else
        Process.daemon if daemonize
        SqsImageProcessor::ProcessManager.generate_pid_file
        config = SqsImageProcessor::Config.load( config_path )
        puts "Loaded config file at #{config_path}."
        puts "Starting SQS Image Processor."
        SqsImageProcessor::Worker.start( config )
      end
    end

    desc "stop", "Stop the SQS Image Processor."

    def stop
      SqsImageProcessor::ProcessManager.kill
    end

    desc "status", "Check whether SQS Image Processor is running."

    def status
      if SqsImageProcessor::ProcessManager.is_running?
        puts "Running with PID #{SqsImageProcessor::ProcessManager.get_pid}."
      else
        puts "Not running."
      end
    end

    desc "generate_config", "Generate an example SQS Image Processor configuration file in the current wokring directory."

    def generate_config
      SqsImageProcessor::Generators.config_generator
    end
  end
end