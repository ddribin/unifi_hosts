require 'test_helper'
require 'unifi_dedupe_hosts/hosts_file'
require 'unifi_dedupe_hosts/host_entry'

module UnifiDedupeHosts
  class HostsFileTest < Test::Unit::TestCase
    test "Read hosts file" do
      input = <<-EOF
127.0.0.1 localhost
# Comment

192.168.1.1 host1 #comment1
192.168.1.2 host2 #comment2
EOF

      f = HostsFile.parse(input)
      assert_not_nil(f)
      headers = [
        '127.0.0.1 localhost',
        '# Comment',
        ''
      ]
      assert_equal(headers, f.headers)
      assert_equal('192.168.1.1', f.entries[0].ip_address)
      assert_equal('192.168.1.2', f.entries[1].ip_address)
    end

    test "Read multiple hosts" do
      input = <<-EOF
# Comment
192.168.1.1 host1 host2 #comment"
EOF

      f = HostsFile.parse(input)
      assert_not_nil(f)
      assert_equal("host1 host2", f.entries[0].hostnames)
    end

    test "Simple Dedup entries" do
      input = <<-EOF
# Comment
192.168.1.1 host1a #comment 1a
192.168.1.1 host1b #comment 1b
192.168.1.2 host2 #comment 2
EOF

      f = HostsFile.parse(input)
      expected = [
        HostEntry.new('192.168.1.1', 'host1b', 'comment 1b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2')
      ]
      actual = f.dedupe_entries
      assert_equal(expected, actual)
    end

    test "Detects out of order duplicates" do
      input = <<-EOF
# Comment
192.168.1.1 host1a #comment 1a
192.168.1.2 host2 #comment 2
192.168.1.1 host1b #comment 1b
EOF

      f = HostsFile.parse(input)
      expected = [
        HostEntry.new('192.168.1.1', 'host1b', 'comment 1b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2')
      ]
      actual = f.dedupe_entries
      assert_equal(expected, actual)
    end

    test "Sorts during dedupe" do
      input = <<-EOF
# Comment
192.168.1.10 host10a #comment 10a
192.168.1.2 host2 #comment 2
192.168.1.10 host10b #comment 10b
EOF

      f = HostsFile.parse(input)
      expected = [
        HostEntry.new('192.168.1.2', 'host2', 'comment 2'),
        HostEntry.new('192.168.1.10', 'host10b', 'comment 10b'),
      ]
      actual = f.dedupe_entries
      assert_equal(expected, actual)
    end

    test "Instrumentation" do
      input = <<-EOF
# Comment
192.168.1.10 host10a #comment 10a
192.168.1.2 host2 #comment 2
192.168.1.10 host10b #comment 10b
EOF

      f = HostsFile.parse(input)

      actual_skipped = []
      actual_kept = []
      f.dedupe_entries do |event, entry|
        actual_skipped.append(entry) if event == HostsFile::SKIP
        actual_kept.append(entry) if event == HostsFile::KEEP
      end

      skipped = [
        HostEntry.new('192.168.1.10', 'host10a', 'comment 10a'),
      ]
      assert_equal(skipped, actual_skipped)

      kept = [
        HostEntry.new('192.168.1.10', 'host10b', 'comment 10b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2'),
      ]
      assert_equal(kept, actual_kept)
    end

  end

end
