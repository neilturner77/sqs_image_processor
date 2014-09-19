require 'yaml'
require 'recursive-open-struct'

module SqsImageProcessor
  class Config
    def self.load( config_path )
      RecursiveOpenStruct.new( YAML.load_file(config_path) )
    end
  end
end