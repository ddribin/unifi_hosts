require 'thor'

module UnifiDedupeHosts
  class CLI < Thor
    desc "format FILE", "Reformats FILE"
    def format(name)
      puts "form"
    end

    desc "sort FILE", "Sorts entries in FILE by IP address"
    def sort(name)
    end

    desc "dedupe FILE", "Removes dpulicate entries in FILE"
    def dedupe(name)
    end
  end
end
