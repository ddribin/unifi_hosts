require_relative 'host_entry'

module UnifiDedupeHosts
  class HostsFile
    attr_reader :headers
    attr_reader :entries

    def initialize(headers, entries)
      @headers = headers
      @entries = entries
    end

    def self.read(input)
      headers = []
      entries = []
      input.each_line do |line|
        line.chomp!
        entry_regxp = /^(\d+\.\d+\.\d+\.\d+)\s+([^#]+)\s+\#(.*)$/
        matches = entry_regxp.match(line)
        if !matches.nil?
          (ip, host, comment) = matches.captures
          entry = HostEntry.new(ip, host, comment)
          entries.append(entry)
        else
          headers.append(line)
        end
      end

      HostsFile.new(headers, entries)
    end

    def dedupe_entries(instrumentation)
      entries_by_ip = @entries.group_by { |e| e.ip_int }
      uniqued_ips = entries_by_ip.transform_values do |entries|
        entry = entries.pop
        if (!instrumentation.nil?)
          entries.each { |e| instrumentation.skipping(e) }
          instrumentation.keeping(entry)
        end
        entry
      end
      sorted_ips = entries_by_ip.keys.sort
      sorted_ips.map { |e| uniqued_ips[e] }
    end
  end
end
