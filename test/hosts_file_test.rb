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

      f = HostsFile.read(StringIO.new(input))
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

      f = HostsFile.read(StringIO.new(input))
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

      f = HostsFile.read(StringIO.new(input))
      expected = [
        HostEntry.new('192.168.1.1', 'host1b', 'comment 1b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2')
      ]
      actual = f.dedupe_entries(nil)
      assert_equal(expected, actual)
    end

    test "Detects out of order duplicates" do
      input = <<-EOF
# Comment
192.168.1.1 host1a #comment 1a
192.168.1.2 host2 #comment 2
192.168.1.1 host1b #comment 1b
EOF

      f = HostsFile.read(StringIO.new(input))
      expected = [
        HostEntry.new('192.168.1.1', 'host1b', 'comment 1b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2')
      ]
      actual = f.dedupe_entries(nil)
      assert_equal(expected, actual)
    end

    test "Sorts during dedupe" do
      input = <<-EOF
# Comment
192.168.1.10 host10a #comment 10a
192.168.1.2 host2 #comment 2
192.168.1.10 host10b #comment 10b
EOF

      f = HostsFile.read(StringIO.new(input))
      expected = [
        HostEntry.new('192.168.1.2', 'host2', 'comment 2'),
        HostEntry.new('192.168.1.10', 'host10b', 'comment 10b'),
      ]
      actual = f.dedupe_entries(nil)
      assert_equal(expected, actual)
    end

    test "Instrumentation" do
      input = <<-EOF
# Comment
192.168.1.10 host10a #comment 10a
192.168.1.2 host2 #comment 2
192.168.1.10 host10b #comment 10b
EOF

      f = HostsFile.read(StringIO.new(input))

      i = InstrumentationSpy.new
      f.dedupe_entries(i)

      skipped = [
        HostEntry.new('192.168.1.10', 'host10a', 'comment 10a'),
      ]
      assert_equal(skipped, i.skipped)

      kept = [
        HostEntry.new('192.168.1.10', 'host10b', 'comment 10b'),
        HostEntry.new('192.168.1.2', 'host2', 'comment 2'),
      ]
      assert_equal(kept, i.kept)
    end

    class InstrumentationSpy
      attr_reader :skipped
      attr_reader :kept
      def initialize
        @skipped = []
        @kept= []
      end

      def skipping(e)
        @skipped.append(e)
      end

      def keeping(e)
        @kept.append(e)
      end
    end

  end

end
