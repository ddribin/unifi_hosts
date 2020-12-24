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

    def ip_int
      octets = @ip_address.match(/(\d+)\.(\d+)\.(\d+)\.(\d+)/).captures
      octets = octets.map { |o| o.to_i }
      int = octets.reduce(0) { |i, o| (i << 8) | o }
      return int
    end

    def to_s
      return "#{@ip_address}\t#{@hostnames}\t\##{comment}\n"
    end

    def ==(other)
      @ip_address == other.ip_address &&
      @hostnames == other.hostnames &&
      @comment == other.comment
    end
  end
end