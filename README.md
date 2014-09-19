# Sqs Image Processor

Queued image processing which utilizes AWS::S3 for storage and AWS::SQS for queueing.

## Installation

Add this line to your application's Gemfile:

    gem 'sqs_image_processor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqs_image_processor

## Usage

Configuration is via a simple YAML file. Run the following command to generate an example in your current working directory.
    
    $ sqs_image_processor generate_config

Edit the settings as required, and when you're ready to start the processing use the following command.

    $ sqs_image_processor start

Add the -d flag to run the process in the background.

SQS Image Processor will search your current working directory for a configuration file. If you'd like to specify a different location use the -c option.

    $ sqs_image_processor start -c path/to/config.yml

To stop the processing use the 'stop' command.

    $ sqs_image_processor stop

## Contributing

1. Fork it ( http://github.com/<my-github-username>/sqs_image_processor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
