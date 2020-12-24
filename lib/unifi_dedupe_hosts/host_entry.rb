module UnifiDedupeHosts
  class HostEntry
    attr_reader :ip_address
    attr_reader :hostnames
    attr_reader :comment

    def initialize(ip_address, hostnames, comment)
      @ip_address = ip_address
      @hostnames = hostnames
      @comment = comment
    end

    def self.parse(string)
      entry_regxp = /^(\d+\.\d+\.\d+\.\d+)\s+([^#]+?)\s+\#(.*)$/
      matches = entry_regxp.match(string)
      return nil if matches.nil?

      (ip, host, comment) = matches.captures
      HostEntry.new(ip, host, comment)
    end

    def ip_int
      octets = @ip_address.match(/(\d+)\.(\d+)\.(\d+)\.(\d+)/).captures
      octets = octets.map { |o| o.to_i }
      int = octets.reduce(0) { |i, o| (i << 8) | o }
      return int
    end

    def to_s
      return "#{@ip_address} #{@hostnames} \##{comment}\n"
    end

    def ==(other)
      @ip_address == other.ip_address &&
      @hostnames == other.hostnames &&
      @comment == other.comment
    end

    def self.to_s(entries)
      ip_width = 0
      host_width = 0
      entries.each do |entry|
        ip_width = max(ip_width, entry.ip_address.length)
        host_width = max(host_width, entry.hostnames.length)
      end

      strings = entries.map do |entry|
        sprintf("%-*s %-*s \#%s", ip_width, entry.ip_address, host_width, entry.hostnames, entry.comment)
      end
      return strings.join("\n")
    end
    def self.max (a,b)
      a>b ? a : b
    end
  end

end