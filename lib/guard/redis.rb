require 'guard'
require 'guard/guard'

module Guard
  class Redis < Guard
    def start
      UI.info "Starting Redis on port #{port}..."
      @pid = nil
      IO.popen("#{executable} -", 'w+') do |server|
        @pid = server.pid
        server.write(config)
        server.close_write
      end
      UI.info "Redis is running with PID #{pid}"
      last_operation_succeeded?
    end

    def stop
      if pid
        UI.info "Sending TERM signal to Redis (#{pid})"
        Process.kill("TERM", pid)
        @pid = nil
        true
      end
    end

    def reload
      UI.info "Reloading Redis..."
      stop
      start
      UI.info "Redis successfully restarted."
    end

    def run_all
      true
    end

    def run_on_change(paths)
      reload if reload_on_change?
    end

    def pidfile_path
      options.fetch(:pidfile) {
        File.expand_path('/tmp/redis.pid', File.dirname(__FILE__))
      }
    end

    def config
      <<"END"
daemonize yes
pidfile #{pidfile_path}
port #{port}
END
    end

    def pid
      (File.exist?(pidfile_path) && File.read(pidfile_path).to_i) || @pid
    end

    def executable
      options.fetch(:executable) { 'redis-server' }
    end

    def port
      options.fetch(:port) { 6379 }
    end

    def last_operation_succeeded?
      $?.success?
    end

    def reload_on_change?
      options.fetch(:reload_on_change) { false }
    end
  end
end
