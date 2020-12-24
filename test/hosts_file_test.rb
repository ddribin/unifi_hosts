require 'test_helper'
require 'unifi_dedupe_hosts/hosts_file'

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
  end
end
