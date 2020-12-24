require 'test_helper'
require 'unifi_hosts/host_entry'

module UnifiHosts
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

    test "Equals when all match" do
      e1 = HostEntry.new("192.168.1.1", "host", '#comment')
      e2 = HostEntry.new("192.168.1.1", "host", '#comment')
      assert_equal(e1, e2)
    end

    test "Not equals with different IP" do
      e1 = HostEntry.new("192.168.1.1", "host", '#comment')
      e2 = HostEntry.new("192.168.1.2", "host", '#comment')
      assert_not_equal(e1, e2)
    end

    test "Not equals with different host" do
      e1 = HostEntry.new("192.168.1.1", "host", '#comment')
      e2 = HostEntry.new("192.168.1.1", "other", '#comment')
      assert_not_equal(e1, e2)
    end

    test "Not equals with different comment" do
      e1 = HostEntry.new("192.168.1.1", "host", '#comment')
      e2 = HostEntry.new("192.168.1.1", "host", '#comment2')
      assert_not_equal(e1, e2)
    end

    test "Array to_s" do
      entries = [
      HostEntry.new("192.168.1.1", "host1", 'comment 1'),
      HostEntry.new("192.168.1.2", "host2a host2b", 'comment 2'),
      HostEntry.new("192.168.1.100", "host100", 'comment 100'),
      ]
      expected = <<-EOF
192.168.1.1   host1         #comment 1
192.168.1.2   host2a host2b #comment 2
192.168.1.100 host100       #comment 100
EOF
      assert_equal(expected.chomp, HostEntry.to_s(entries))
    end

    test "Parse valid entry" do
      e = HostEntry.parse('192.168.1.1 host #comment')
      assert_equal(HostEntry.new("192.168.1.1", "host", "comment"), e)
    end

    test "No comment does not parse" do
      assert_nil(HostEntry.parse('127.0.0.1 localhost'))
    end

    test "Blank line does not parse" do
      assert_nil(HostEntry.parse(''))
    end

    test "Comment does not parse" do
      assert_nil(HostEntry.parse('# Comment'))
    end

    test "Tabs are stripped" do
      e = HostEntry.parse("192.168.1.1\t host\t \#comment")
      assert_equal(HostEntry.new("192.168.1.1", "host", "comment"), e)
    end
  end
end
