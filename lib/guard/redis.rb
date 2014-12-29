require 'guard/compat/plugin'

module Guard
  class Redis < Plugin
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
      shutdown_redis
      @pid = nil
      true
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

    def shutdown_redis
      return UI.info "No instance of Redis to stop." unless pid
      return UI.info "Redis (#{pid}) was already stopped." unless process_running?
      UI.info "Sending TERM signal to Redis (#{pid})..."
      Process.kill("TERM", pid)

      return if shutdown_retries == 0
      shutdown_retries.times do
        return UI.info "Redis stopped." unless process_running?
        UI.info "Redis is still shutting down. Retrying in #{ shutdown_wait } second(s)..."
        sleep shutdown_wait
      end
      UI.error "Redis didn't shut down after #{ shutdown_retries * shutdown_wait } second(s)."
    end

    def pidfile_path
      options.fetch(:pidfile) {
        File.expand_path('/tmp/redis.pid', File.dirname(__FILE__))
      }
    end

    def config
      result = <<"END"
daemonize yes
pidfile #{pidfile_path}
port #{port}
END
      result << "logfile #{logfile}" if capture_logging?
      result
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

    def logfile
      options.fetch(:logfile) {
        if capture_logging? then "log/redis_#{port}.log" else 'stdout' end
      }
    end

    def shutdown_retries
      options.fetch(:shutdown_retries) { 0 }
    end

    def shutdown_wait
      options.fetch(:shutdown_wait) { 0 }
    end

    def last_operation_succeeded?
      $?.success?
    end

    def reload_on_change?
      options.fetch(:reload_on_change) { false }
    end

    def process_running?
      begin
        Process.getpgid pid
        true
      rescue Errno::ESRCH
        false
      end
    end

    def capture_logging?
      options.fetch(:capture_logging) { false }
    end
  end
end
