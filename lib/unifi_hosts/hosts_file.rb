require_relative 'host_entry'

module UnifiHosts
  class HostsFile
    attr_reader :headers
    attr_reader :entries

    def initialize(headers, entries)
      @headers = headers
      @entries = entries
    end

    def self.parse(string)
      return self.read(StringIO.new(string))
    end

    def self.read(input)
      headers = []
      entries = []
      input.each_line do |line|
        line.chomp!
        entry = HostEntry.parse(line)
        if entry.nil?
          headers.append(line)
        else
          entries.append(entry)
        end
      end

      HostsFile.new(headers, entries)
    end

    def sort_entries
      HostEntry.sort_by_ip(@entries)
    end

    def dedupe_entries(&block)
      HostEntry.dedupe(@entries, &block)
    end
  end
end
