require 'fileutils'

module SqsImageProcessor
  module Generators
    def self.config_generator
      current_directory = File.dirname(__FILE__)
      working_directory = File.expand_path(Dir.pwd)
      target_path = File.join(working_directory, 'sqs_image_processor_config.yml')

      if File.exists?(target_path)
        puts "Config file already exists at this location."
      else
        template = File.join(current_directory, 'templates', 'sqs_image_processor_config.yml')
        FileUtils.cp(template, target_path)
        puts "Successfully generated config file in current working directory."
      end
    end
  end
end