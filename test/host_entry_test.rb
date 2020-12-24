require 'test_helper'
require 'unifi_dedupe_hosts/host_entry'

module UnifiDedupeHosts
  class HostEntryTest < Test::Unit::TestCase
    test "IP integer" do
      e = HostEntry.new("192.168.1.2", "host2", '#comment')
      assert_equal((192 << 24) | (168 << 16) | (1 << 8) | 2, e.ip_int)
    end

    test "Sorting by IP integer" do
      e1 = HostEntry.new("192.168.1.2", "host2", '#comment')
      e2 = HostEntry.new("192.168.1.10", "host10", '#comment')
      entries = [e1, e2]

      sorted_entries = entries.sort_by { |e| e.ip_int }

      assert_equal([e1, e2], sorted_entries)
    end
  end
end
