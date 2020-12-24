require 'thor'

require_relative 'hosts_file'
require_relative 'host_entry'

module UnifiHosts
  class CLI < Thor
    BASE_COMMAND = File.basename($0)

    class_option :verbose, :type => :boolean, :aliases => '-v', :desc => "Enable verbose output"
    class_option :output, :type => :string, :aliases => '-o', :desc => "Output file"
    class_option :in_place, :type => :boolean, :aliases => '-o', :desc => "Overwrite input file"
    class_option :dry_run, :type => :boolean, :aliases => '-n', :desc => "Don't write to output file"

    def self.exit_on_failure?
      true
    end

    desc "format FILE", "Reformats FILE"
    def format(input_file)
      transform_entries(input_file) do |hosts_file|
        hosts_file.entries
      end
    end

    desc "sort FILE", "Sorts entries in FILE by IP address"
    def sort(input_file)
      transform_entries(input_file) do |hosts_file|
        hosts_file.sort_entries
      end
    end

    desc "dedupe FILE", "Removes dpulicate entries in FILE"
    def dedupe(input_file)
      transform_entries(input_file) do |hosts_file|
        hosts_file.dedupe_entries(&method(:print_dedupe_event))
      end
    end

    no_commands do
      def read_hosts_file(file)
        hosts_file = with_input(file) do |input|
          HostsFile.read(input)
        end
        return hosts_file
      end

      def with_input(file)
        result = nil
        begin
          if file == "-"
            result = yield(STDIN)
          else
            result = File.open(file) { |input| yield input }
          end
        rescue Errno::ENOENT, Errno::EACCES => e
          $stderr.puts "#{BASE_COMMAND} #{current_command}: #{e.message}"
          result = nil
        end
        return result
      end

      def print_dedupe_event(event, entry)
        return if !@options.verbose

        verb = case event
        when HostsFile::SKIP
          "SKIP: "
        when HostsFile::KEEP
          "KEEP: "
        end
        $stderr.puts "#{verb}#{entry}"
      end

      def validate_output
        if options[:output] && options[:in_place]
          error "Cannot specify both --output and --in-place"
          return false
        end
        return true
      end

      def output(input_file:, headers:, entries:)
        with_output(input_file: input_file) do |o|
          headers.each { |h| o.puts h }
          o.puts HostEntry.to_s(entries)
        end
      end

      def transform_entries(input_file)
        return 1 if !validate_output
        hosts_file = read_hosts_file(input_file)
        return 1 if hosts_file.nil?
        
        with_output(input_file: input_file) do |o|
          hosts_file.headers.each { |h| o.puts h }
          entries = yield hosts_file
          o.puts HostEntry.to_s(entries)
        end
      end

      # Opens output file and calls the block with the IO handle
      def with_output(input_file:)
        output_file = options[:output] 
        output_file = input_file if options[:in_place]
        output_file ||=  "-"

        result = 0
        begin
          if output_file == '-'
            result = yield(STDOUT)
          else
            if options[:dry_run]
              $stderr.puts "Dry run: Not writing to #{output_file}"
              output_file = '/dev/null' if options[:dry_run]
            end

            File.open(output_file, "w") { |output|  yield output }
          end
        rescue Errno::ENOENT, Errno::EACCES => e
          error "#{e.message}"
          result = 1
        end
        return result
      end

      def error(message)
        $stderr.puts "#{BASE_COMMAND} #{current_command}: #{message}"
      end

      # Override to get current command
      def initialize(args = [], local_options = {}, config = {})
        super(args, local_options, config)
        @current_command = config[:current_command]
      end

      def current_command
        return @current_command.name
      end

    end

    # Override start to allow commands to return the exit code
    def self.start(given_args = ARGV, config = {})
      exit_code = super given_args, config
      exit_code = 0 if !exit_code.is_a? Integer
      exit(exit_code)
    end

  end
end
