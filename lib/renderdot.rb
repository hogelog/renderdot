# frozen_string_literal: true

require_relative "renderdot/version"
require_relative "renderdot/server"

require "erb"
require "tempfile"

module Renderdot
  TEMPLATE = File.read(File.expand_path("../../d3.html.erb", __FILE__))

  class << self
    def livedraw_html(dot, bind: "localhost", port: 4567, logger: Logger.new(nil))
      Renderdot::Server.new(dot: dot, bind: bind, port: port, logger: logger)
    end

    def render_html(dot, livedraw_endpoint: nil, open: false)
      html = ERB.new(TEMPLATE).result(binding)
      if open
        Tempfile.open(["renderdot", ".html"]) do |f|
          f.write(html)
          f.flush
          open_file(f.path)
        end
      end
      html
    end

    def open_file(path)
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|emc/
        system("start #{path}")
      when /darwin|mac os/
        system("open #{path}")
      when /linux/
        system("xdg-open #{path}")
      end
    end
  end
end
