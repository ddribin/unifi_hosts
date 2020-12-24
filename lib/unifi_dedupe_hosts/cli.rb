
require 'optparse'
require 'ostruct'
require 'pp'

require_relative 'hosts_file'

module UnifiDedupeHosts
  class CLI
    def initialize(command)
      @command = command
      @usage = "Usage: #{@command} [OPTIONS] <hosts-file>"
    end

    def run(args)
      result = parse_options(args)
      return result if result != 0

      begin
        hosts_file = File.open(@options.input_file) do |input|
          HostsFile.read(input)
        end
        pp hosts_file
      rescue Errno::ENOENT, Errno::EACCES => e
        $stderr.puts "#{@command}: #{e.message}"
        result = 1
      end
      return result
    end

    def parse_options(args)
      options = OpenStruct.new
      options.dry_run = false
      options.verbose = false

      opts = OptionParser.new do |opts|
        opts.banner = @usage
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-n", "--dry-run", "Don't write to output file") do
          options.dry_run = true
        end

        opts.on("-v", "--verbose", "Enable verbose output") do
          options.verbose = true
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
      opts.parse!(args)

      if args.size != 1
        $stderr.puts @usage
        return 1
      end

      options.input_file = args[0]

      @options = options
      return 0
    end    
  end
end