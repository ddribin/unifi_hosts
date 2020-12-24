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
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?

      with_output do |o|
        hosts_file.headers.each { |h| o.puts h }
        entries = hosts_file.entries
        o.puts HostEntry.to_s(entries)
      end
    end

    desc "sort FILE", "Sorts entries in FILE by IP address"
    def sort(input_file)
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?
      
      with_output do |o|
        hosts_file.headers.each { |h| o.puts h }
        entries = hosts_file.sort_entries
        o.puts HostEntry.to_s(entries)
      end
    end

    desc "dedupe FILE", "Removes dpulicate entries in FILE"
    def dedupe(input_file)
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?
      
      with_output do |o|
        hosts_file.headers.each { |h| o.puts h }
        entries = hosts_file.dedupe_entries(&method(:print_dedupe_event))
        o.puts HostEntry.to_s(entries)
      end
    end

    no_commands do
      def read_hosts_file(file)
        hosts_file = nil
        begin
          hosts_file = File.open(file) do |input|
            HostsFile.read(input)
          end
        rescue Errno::ENOENT, Errno::EACCES => e
          $stderr.puts "#{BASE_COMMAND} #{current_command}: #{e.message}"
        end
        return hosts_file
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

      # Opens output file and calls the block with the IO handle
      def with_output
        result = 0
        output_file =  options[:output] || "-"
        if output_file == '-'
          result = yield(STDOUT)
        else
          begin
            if options[:dry_run]
              $stderr.puts "Dry run: Not writing to #{output_file}"
              output_file = '/dev/null' if options[:dry_run]
            end
            result = File.open(output_file, "w") { |io|  yield io }
          rescue Errno::ENOENT, Errno::EACCES => e
            $stderr.puts "#{BASE_COMMAND} #{current_command}: #{e.message}"
            result = 1
          end
        end
        return result
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
