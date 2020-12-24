require 'thor'

require_relative 'hosts_file'
require_relative 'host_entry'

module UnifiHosts
  class CLI < Thor
    BASE_COMMAND = File.basename($0)

    class_option :verbose, :type => :boolean, :aliases => '-v', :desc => "Enable verbose output"

    def self.exit_on_failure?
      true
    end

    desc "format FILE", "Reformats FILE"
    def format(input_file)
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?

      hosts_file.headers.each { |h| puts h }
      entries = hosts_file.entries
      puts HostEntry.to_s(entries)
    end

    desc "sort FILE", "Sorts entries in FILE by IP address"
    method_option :dry_run, :type => :boolean, :aliases => '-n', :desc => "Dry run"
    def sort(input_file)
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?
      
      hosts_file.headers.each { |h| output h }
      entries = hosts_file.sort_entries
      output HostEntry.to_s(entries)
    end

    desc "dedupe FILE", "Removes dpulicate entries in FILE"
    method_option :dry_run, :type => :boolean, :aliases => '-n', :desc => "Dry run"
    def dedupe(input_file)
      hosts_file = read_hosts_file(input_file)
      return 1 if hosts_file.nil?
      
      hosts_file.headers.each { |h| output h }
      entries = hosts_file.dedupe_entries(&method(:print_dedupe_event))
      output HostEntry.to_s(entries)
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
          "Skip: "
        when HostsFile::KEEP
          "Keep: "
        end
        $stderr.puts "#{verb}#{entry}"
      end

      def output(string)
        puts string if !@options[:dry_run]
      end

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
      exit_code = 0 if exit_code.nil?
      exit(exit_code)
    end

  end
end
