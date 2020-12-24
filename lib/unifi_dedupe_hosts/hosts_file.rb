require_relative 'host_entry'

module UnifiDedupeHosts
  class HostsFile
    SKIP = 1
    KEEP = 2

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
      entries_by_ip = @entries.group_by { |e| e.ip_int }
      sorted_ips = entries_by_ip.keys.sort
      sorted_entries = sorted_ips.map do |ip|
        entries_by_ip[ip]
      end
      sorted_entries.flatten
    end

    def dedupe_entries
      entries_by_ip = @entries.group_by { |e| e.ip_int }
      uniqued_ips = entries_by_ip.transform_values do |entries|
        entry = entries.pop
        if block_given?
          entries.each { |e| yield(SKIP, e) }
          yield(KEEP, entry)
        end
        entry
      end
      sorted_ips = entries_by_ip.keys.sort
      sorted_ips.map { |e| uniqued_ips[e] }
    end
  end
end
