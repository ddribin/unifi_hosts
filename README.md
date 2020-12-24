# UniFi Hosts

`unfi-hosts` is a script that can transform an `/etc/hosts` file for a UniFi Security Gateway (USG). Some of the transforms are:

- Reformat so that the columns are evenly spaced out.
- Sort entries by IP address.
- Remove duplicate IP addresses.

Removing duplicates can help fix issues with incorrectly reported hostnames.

## Installation

Install it via Ruby Gems:

    $ gem install unifi_hosts

## Usage

TODO: Write usage instructions here

## Duplicate IP Addresses

Removing duplicates is important because depulicates can cause issues doing reverse lookups. The USG will use the first entry found in `/etc/hosts`. However if a host changes its name, then then new name is appended to the end, leaving the original entry. This causes the old name to be used for reverse lookups.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddribin/unifi_hosts.
