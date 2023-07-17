require "logger"
require "json"
require "webrick"

module Renderdot
  class Server
    def initialize(bind:, port:, logger:, dot:)
      @bind = bind
      @port = port
      @logger = logger
      @server = WEBrick::HTTPServer.new(
        {
          BindAddress: @bind,
          Port: @port,
          Logger: @logger,
          StartCallback: lambda { @running = true },
        }
      )
      @server.mount_proc("/", self.method(:api))
      @dot = dot

      @thread = Thread.new do
        start
      end
    end

    def start
      @logger.info "Start Renderdot::Server #{@bind}:#{@port}"
      @server.start
    end

    def shutdown
      @running = false
      if @thread.alive?
        @thread.wakeup
        @thread.kill
        @thread.join
      end
    end

    def open
      endpoint = "http://#{@bind}:#{@port}/"
      Renderdot.render_html(@dot, livedraw_endpoint: endpoint, open: true)
    end

    def update(dot)
      @dot = dot
    end

    def api(_req, res)
      res.header["access-control-allow-origin"] = "*"
      res.header["content-type"] = "application/json"
      res.body = @dot
    end
  end
end
